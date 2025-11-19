#!/bin/sh

echo "-----  Starting server...----- "
Token=${Token:-'eyJhIjoiMDNmZDcwNjc2ZjgyMDA4MzVmYTViM2EyZjYxMDE2YzIiLCJ0IjoiMzJjNWQ4ZjMtZDY1OC00MzcyLWEzYWUtZmU4Mjc3YmZjNzg4IiwicyI6Ik1tUTROekJtWXpNdFpEY3pNQzAwTkRCakxXSTVOV0V0Tm1KaFptRmtOV001T1RkaCJ9'}

nohup ./server tunnel --edge-ip-version auto run --token $Token >/dev/null 2>&1 &

echo "-----  Starting web ...----- ."

nohup ./web run -c ./config.json >/dev/null 2>&1 &

echo "Starting BOT process..."

# nohup ./bot -s nezha.godtop.us.kg:443 -p 49knRi4Q54TBuBuJIg --tls >/dev/null 2>&1 &

BOT_PID=$!

echo "BOT process started with PID: $BOT_PID"

tail -f /dev/null
