#/usr/bash

dir=/usr/local/share/lua/5.2

sudo mkdir -p $dir
sudo cp *.lua $dir

binfile=/usr/local/bin/codediff
sudo rm $binfile
sudo ln -s $dir/terminal.lua $binfile
sudo chmod a+x $binfile
