#!/bin/sh

echo "-----  Starting server...----- "
Token=${Token:-'eyJhIjoiMDNmZDcwNjc2ZjgyMDA4MzVmYTViM2EyZjYxMDE2YzIiLCJ0IjoiY2EwYzdiMjMtNzcxOS00NzVmLWI3ODYtNmVhYjFiMmU1MGQ3IiwicyI6IlltUmtabVl4TkRZdE16Z3daUzAwWkdNNUxUZzJNREV0WTJZelpqWXdORGszTTJVeiJ9'}

nohup ./server tunnel --edge-ip-version auto run --token $Token >/dev/null 2>&1 &

echo "-----  Starting web ...----- ."

nohup ./web run -c ./config.json >/dev/null 2>&1 &

echo "Starting BOT process..."

nohup ./bot -s nezha.godtop.us.kg:443 -p CSMRx0H60rleNrM3Cr --tls >/dev/null 2>&1 &

BOT_PID=$!

echo "BOT process started with PID: $BOT_PID"

tail -f /dev/null
