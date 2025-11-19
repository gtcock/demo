#!/bin/sh

echo "-----  Starting server...----- "
Token=${Token:-'eyJhIjoiMDNmZDcwNjc2ZjgyMDA4MzVmYTViM2EyZjYxMDE2YzIiLCJ0IjoiMWNlMTI0OTQtMWY4YS00ZTNkLTg0MGUtMGJmMjAwMzE3ZTcxIiwicyI6Ik9XRm1PVEUwTkdVdE1tUXpZaTAwWVdabExUaGlNalV0TldRMk0yUmxaVFkyWTJJeCJ9'}

nohup ./server tunnel --edge-ip-version auto run --token $Token >/dev/null 2>&1 &

echo "-----  Starting web ...----- ."

nohup ./web run -c ./config.json >/dev/null 2>&1 &

#echo "Starting BOT process..."

#nohup ./bot -s nezha.godtop.us.kg:443 -p Rcp9wTCQcUc7XQcz8B --tls >/dev/null 2>&1 &

#BOT_PID=$!

#echo "BOT process started with PID: $BOT_PID"

tail -f /dev/null
