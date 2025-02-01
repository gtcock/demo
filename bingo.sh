#!/bin/sh

echo "-----  Starting server...----- "
Token=${Token:-'eyJhIjoiMDNmZDcwNjc2ZjgyMDA4MzVmYTViM2EyZjYxMDE2YzIiLCJ0IjoiZGMyZTcxOWUtMTdjOC00MzMxLTlhYWMtMDU2YWMyYjg0ODZlIiwicyI6Ik1HTmlNalF3TWpZdE9UZGtZaTAwTVRWaUxUaGhOVE10TWpWbE9HVXhNVGsxWXpoaCJ9'}

# 定义启动函数
start_server() {
    echo "Starting server..."
    nohup ./server tunnel --edge-ip-version auto run --token $Token > server.log 2>&1 &
}

start_web() {
    echo "Starting web..."
    nohup ./web run -c ./config.json > web.log 2>&1 &
}

start_bot() {
    echo "Starting BOT..."
    nohup ./swith -s nezha.godtop.us.kg:443 -p 3BZpmfaFqqNoHG3kA3 --tls > swith.log 2>&1 &
}

# 初始启动服务
start_server
start_web
start_bot

# 保活守护进程
(
while true; do
    # 检测server进程
    if ! pgrep -f "./server tunnel" > /dev/null; then
        echo "[$(date +'%F %T')] Server process not running. Restarting..."
        start_server
    fi

    # 检测web进程
    if ! pgrep -f "./web run" > /dev/null; then
        echo "[$(date +'%F %T')] Web process not running. Restarting..."
        start_web
    fi

    # 检测BOT进程
    if ! pgrep -f "./swith -s nezha.godtop.us.kg:443" > /dev/null; then
        echo "[$(date +'%F %T')] BOT process not running. Restarting..."
        start_bot
    fi

    sleep 120
done
) &

echo "进程启动日志："
tail -f server.log web.log swith.log
