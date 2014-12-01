Custom ~/.vim configuration. Forked from scrooloose/vimfiles.

Installation
============

Clone the repo:
`git clone https://github.com/Laeryn/vimfiles.git ~/.vim`

Grab the plugin submodules:
`cd ~/.vim && git submodule init && git submodule update`

Update plugins to latest version:
`cd ~/.vim && git submodule foreach git pull origin master`

Make sure vim finds the vimrc file by either symlinking it:
`ln -s ~/.vim/vimrc ~/.vimrc`

or by sourcing it from  your own ~/.vimrc:
`source ~/.vim/vimrc`
