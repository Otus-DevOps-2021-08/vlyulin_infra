#!/bin/sh
apt update
echo "sleep 1m for install updates"; sleep 1m; echo "start install ruby"
apt install -y ruby-full ruby-bundler build-essential
