sudo apt-get install git ccache automake flex lzop bison gperf build-essential zip curl zlib1g-dev g++-multilib libxml2-utils bzip2 libbz2-dev libbz2-1.0 libghc-bzlib-dev squashfs-tools pngcrush schedtool dpkg-dev liblz4-tool make optipng maven libssl-dev pwgen libswitch-perl policycoreutils minicom libxml-sax-base-perl libxml-simple-perl bc libc6-dev-i386 lib32ncurses5-dev libx11-dev lib32z-dev libgl1-mesa-dev xsltproc unzip device-tree-compiler python2 python3      

mkdir ~/Kernel

cd ~/Kernel

git clone https://android.googlesource.com/platform/system/tools/mkbootimg tools -b master-kernel-build-2022 --depth=1

cd ~/Kernel

git clone --recursive https://github.com/kamikaonashi/kernel_xiaomi_sm8350 -b 15 android-kernel --depth=1

echo "FORMAT_MKBOOTING=$(echo `tools/unpack_bootimg.py --boot_img=boot-source.img --format mkbootimg`)" 

cd ~/Kernel/android-kernel

mkdir -p ~/Kernel/android-kernel/out

export PATH=~/Kernel/toolchain/bin:$PATH

vim build.sh

#!/bin/bash
args="-j2 \
O=out \
ARCH=arm64 \
CROSS_COMPILE=aarch64-linux-gnu- \
CC=clang \
CROSS_COMPILE_COMPAT=arm-linux-gnueabi- "
make ${args} venus_defconfig
make ${args}

bash build.sh

cd ~/Kernel

git clone https://github.com/osm0sis/AnyKernel3 --depth=1 AnyKernel3

sed -i 's/do.devicecheck=1/do.devicecheck=0/g' AnyKernel3/anykernel.sh

sed -i 's!BLOCK=/dev/block/platform/omap/omap_hsmmc.0/by-name/boot;!BLOCK=auto;!g' AnyKernel3/anykernel.sh

sed -i 's/IS_SLOT_DEVICE=0;/is_slot_device=auto;/g' AnyKernel3/anykernel.sh

cp android-kernel/out/arch/arm64/boot/Image AnyKernel3/

rm -rf AnyKernel3/.git* AnyKernel3/README.md

cd ~/Kernel

tools/unpack_bootimg.py --boot_img boot-source.img

cp android-kernel/out/arch/Arm64/boot/Image out/kernel

tools/mkbootimg.py ${{ env.FORMAT_MKBOOTING }} -o boot.img
