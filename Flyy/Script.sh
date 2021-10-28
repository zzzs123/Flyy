#!/bin/sh

#  Script.sh
#  Flyy
#
#  Created by sillyb on 2021/10/28.
#

# install for current user?

dir="$HOME/Library/Application Support/Flyy"
echo "$dir/proxy_conf"

if [ ! -d "$dir" ];then
sudo mkdir -p "$dir"
echo "mkdir Flyy"
else
echo "Flyy exists"
fi

cd `dirname "${BASH_SOURCE[0]}"`
sudo \cp -fv proxy_conf "$dir"
sudo \cp -rfv v2ray-core "$dir"

sudo chown root:admin "$dir/proxy_conf"
sudo chmod a+rx "$dir/proxy_conf"
sudo chmod +s "$dir/proxy_conf"

echo "$dir/proxy_conf"

#sudo chmod -R 755 "$dir"
