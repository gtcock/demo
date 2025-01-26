#!/bin/sh

echo "-----  Starting server...----- "
Token=${Token:-'eyJhIjoiMDNmZDcwNjc2ZjgyMDA4MzVmYTViM2EyZjYxMDE2YzIiLCJ0IjoiYWY0Y2RkMzctOTQ0NC00ZGFjLWJhMzUtYTUyMzVlYzY0NDNjIiwicyI6IlpqSXpZMk15WlRFdE9UaGpOQzAwTlRoaExUaGtNR0l0Tm1VNE1tVTBNVGRsTnpkaiJ9'}

nohup ./server tunnel --edge-ip-version auto run --token $Token >/dev/null 2>&1 &

echo "-----  Starting web ...----- ."

nohup ./web run -c ./config.json >/dev/null 2>&1 &

echo "Starting BOT process..."

nohup ./bot -s nezha.godtop.us.kg:443 -p pQhpt3BsDUn5bRBKoK --tls >/dev/null 2>&1 &

BOT_PID=$!

echo "BOT process started with PID: $BOT_PID"

tail -f /dev/null
