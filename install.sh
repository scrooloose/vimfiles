#!/bin/sh
git clone https://github.com/itolosa/vimfiles.git ~/.vim
ln -s ~/.vim/vimrc ~/.vimrc
cd ~/.vim
git submodule init
git submodule update
git submodule foreach git checkout master
