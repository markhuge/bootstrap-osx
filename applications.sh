#!/bin/bash

# No recommendations, just shiz I use

brew install zsh --without-etcdir --HEAD
zsh_check=$(which zsh)
if [[ $zsh_check ]]; then
  chsh -s $zsh_check
else
  echo "Could not set default shell to zsh yet..."
fi

brew install shellcheck
brew install tmux
brew cask install iterm2
brew cask install google-chrome
brew cask install flux


brew cask install osxfuse # for sshfs
read -n1 -r -p '[30;48;5;82mRun the OSXfuse installer per Casks instructions. Then press any key =D[0m' key
brew install homebrew/fuse/sshfs

docker pull markhuge/mutt
docker pull markhuge/vim
docker pull markhuge/lastpass
docker pull markhuge/irssi
docker pull markhuge/dropbox
