#!/bin/bash
ln -s ~/.vim/vimrc ~/.vimrc
pushd ~/.vim
git submodule init
git submodule update
git submodule foreach git checkout master
popd
