#!/bin/bash

./hostprepare-packages.sh
./hostprepare-settings.sh
./hostprepare-net.sh
#./hostprepare-dhcp.sh

echo "Setup complete. Please reboot the system."