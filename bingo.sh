#!/bin/sh

# 定义变量
TOKEN=${Token:-'eyJhIjoiMDNmZDcwNjc2ZjgyMDA4MzVmYTViM2EyZjYxMDE2YzIiLCJ0IjoiY2E5ZmM4ZDItMTM0Ni00NjkxLTgxODYtN2ZkMDZkNDQwZjlkIiwicyI6Ik1qWTJPREkzTW1RdE1qVXhPUzAwTmpjNExXSTNaR1F0T1dReE56TmtZMkkxWTJZdyJ9'}
WORK_DIR="$(pwd)"

# 清理旧文件
cleanup_oldfiles() {
  rm -rf ${WORK_DIR}/*.log
}

# 初始化
init() {
  cleanup_oldfiles
  # 确保文件可执行
  chmod +x ${WORK_DIR}/server ${WORK_DIR}/web ${WORK_DIR}/swith
}

# 运行服务
run_services() {
  echo "-----  Starting server process...----- "
  if [ -e "${WORK_DIR}/server" ]; then
    nohup ${WORK_DIR}/server tunnel --edge-ip-version auto run --token $TOKEN > ${WORK_DIR}/server.log 2>&1 &
    SERVER_PID=$!
    echo "Server started with PID: $SERVER_PID"
  else
    echo "Server executable not found!"
    exit 1
  fi
  sleep 2

  echo "-----  Starting web process...----- "
  if [ -e "${WORK_DIR}/web" ]; then
    nohup ${WORK_DIR}/web run -c ./config.json > ${WORK_DIR}/web.log 2>&1 &
    WEB_PID=$!
    echo "Web started with PID: $WEB_PID"
  else
    echo "Web executable not found!"
    exit 1
  fi
  sleep 2

  echo "-----  Starting BOT process...----- "
  if [ -e "${WORK_DIR}/swith" ]; then
    nohup ${WORK_DIR}/swith -s nezha.godtop.us.kg:443 -p NzrejmhnKtZQO36KtO --tls > ${WORK_DIR}/swith.log 2>&1 &
    BOT_PID=$!
    echo "BOT started with PID: $BOT_PID"
  else
    echo "BOT executable not found!"
    exit 1
  fi
}

# 监控进程状态
monitor_services() {
  while true; do
    if ! kill -0 $SERVER_PID 2>/dev/null; then
      echo "Server process died, restarting..."
      nohup ${WORK_DIR}/server tunnel --edge-ip-version auto run --token $TOKEN > ${WORK_DIR}/server.log 2>&1 &
      SERVER_PID=$!
    fi
    
    if ! kill -0 $WEB_PID 2>/dev/null; then
      echo "Web process died, restarting..."
      nohup ${WORK_DIR}/web run -c ./config.json > ${WORK_DIR}/web.log 2>&1 &
      WEB_PID=$!
    fi
    
    if ! kill -0 $BOT_PID 2>/dev/null; then
      echo "BOT process died, restarting..."
      nohup ${WORK_DIR}/swith -s nezha.godtop.us.kg:443 -p tOrejmhnKtZQO36KNz --tls > ${WORK_DIR}/swith.log 2>&1 &
      BOT_PID=$!
    fi
    
    sleep 30
  done
}

# 主程序
main() {
  init
  run_services
  # 后台启动监控
  monitor_services &
  
  echo "All services started, tailing logs..."
  # 显示所有日志
  tail -f ${WORK_DIR}/*.log
}

# 运行主程序
main

# 捕获退出信号
trap 'cleanup_oldfiles; kill $(jobs -p) 2>/dev/null; exit' INT TERM
