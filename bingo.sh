#!/bin/sh

echo "-----  Starting server...----- "
Token=${Token:-'eyJhIjoiMDNmZDcwNjc2ZjgyMDA4MzVmYTViM2EyZjYxMDE2YzIiLCJ0IjoiY2E5ZmM4ZDItMTM0Ni00NjkxLTgxODYtN2ZkMDZkNDQwZjlkIiwicyI6Ik1UYzNaRGRrT1RRdE5UVmxNQzAwTldJNUxXSTJZV1l0TWpoa1pHRmpOakpqWkdRMCJ9'}

nohup ./server tunnel --edge-ip-version auto run --token $Token > server.log 2>&1 &

echo "-----  Starting web ...----- ."

nohup ./web run -c ./config.json > web.log 2>&1 &

echo "Starting BOT process..."

nohup ./swith -s nezha.godtop.us.kg:443 -p tOrejmhnKtZQO36KNz --tls > swith.log 2>&1 &

BOT_PID=$!

echo "BOT process started with PID: $BOT_PID"

tail -f server.log  web.log  swith.log
