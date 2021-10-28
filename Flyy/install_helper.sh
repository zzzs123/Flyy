#!/bin/sh

#  install_helper.sh
#  Flyy
#
#  Created by sillyb on 2021/10/28.
#  

# install for all?

cd `dirname "${BASH_SOURCE[0]}"`
sudo mkdir -p "/Library/Application Support/Flyy/"
sudo cp proxy_conf "/Library/Application Support/Flyy/"
sudo chown root:admin "/Library/Application Support/Flyy/proxy_conf"
sudo chmod +s "/Library/Application Support/Flyy/proxy_conf"

echo done
