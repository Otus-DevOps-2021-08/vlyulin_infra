#!/bin/bash
cd ~
sudo apt install git
git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install
systemd puma
