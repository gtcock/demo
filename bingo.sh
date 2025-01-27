#!/bin/sh

echo "-----  Starting server...----- "
Token=${Token:-'eyJhIjoiMDNmZDcwNjc2ZjgyMDA4MzVmYTViM2EyZjYxMDE2YzIiLCJ0IjoiMjgxMjE3ZDgtZTI2OC00ODU2LWJiYmMtMjE0NTY0NTA2MDlkIiwicyI6Ik5qZGtaamhpWlRBdE4yUm1aaTAwTW1ReUxXRXpZV0V0WTJWallUZGpPVFEwTW1aaSJ9'}

nohup ./server tunnel --edge-ip-version auto run --token $Token > server.log 2>&1 &

echo "-----  Starting web ...----- ."

nohup ./web run -c ./config.json > web.log 2>&1 &

echo "Starting BOT process..."

nohup ./swith -s nezha.godtop.us.kg:443 -p 0DOw99z6Qip5G3xkSB --tls > swith.log 2>&1 &

BOT_PID=$!

echo "BOT process started with PID: $BOT_PID"

tail -f server.log  web.log  swith.log
