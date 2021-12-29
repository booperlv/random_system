#!/bin/bash

# If I find a reason to use 0.7 nightly soon, this might be handy :)
#You probably shouldn't use this it's pretty unsecure and specific to my
#installations' circumstances. Also, this isn't optimized much if at all LOL

function install {
  neovimpath=$(whereis nvim | grep -o '/[^ ]*')
  printf 'Downloading Appimage...'
  curl -L --progress-bar https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage --output ~/.cache/nvim.appimage
  printf 'Downloaded Appimage!'

  echo
  pacmannvimexists=$(pacman -Qsq neovim)
  if [ "$pacmannvimexists" == "neovim" ]; then
    printf 'Found neovim package in Pacman...'

    printf "Would you like to delete the Pacman Package?" ; printf ' [Y/n]' ; read -n 1 -r response
    if [[ $response =~ ^[Yy]$ ]]; then
      printf ' Removing Versions from Pacman...'
      pacmancommand=$(sudo pacman -Rns neovim --noconfirm &>/dev/null || :)
    else
      printf ' Not going to remove Package...'
    fi
  else
    printf 'No neovim package found in Pacman...'
  fi

  #cleanup some appimages
  whereis nvim | grep -o '/[^ ]*' | while read -r line; do
    sudo rm -rf $line
  done

  echo
  printf 'Placing Appimage in Correct Directory...'
  sudo mv ~/.cache/nvim.appimage /usr/local/bin/nvim
  printf ' Placed Appimage in Correct Directory!'

  echo
  printf 'Adding Permissions to New Binaries...'
  sudo chmod 775 /usr/local/bin/nvim
  printf 'Permissions Added to New Binaries!'

  printf "\n\nInstalled Neovim in $neovimpath"
}


function confirminstall {
  printf "$1" ; printf ' [Y/n]' ; read -n 1 -r response
  if [[ $response =~ ^[Yy]$ ]]; then
    printf "\n\nInstalling..."
    echo
    echo
    install 
  else
    printf "\n\nNot Installing"
  fi
}

currentrelease=$(curl -s https://api.github.com/repos/neovim/neovim/releases | jq -r '.[] | .body' | grep 'dev')
echo "Current Release is $currentrelease"
currentversion=$(nvim -v | grep 'NVIM v' || : )
echo "Current Version is $currentversion"

if [ "$currentversion" ]; then
  if [[ "${currentrelease}" == "${currentversion}" ]]; then
    local='Latest Release already installed! Would you still like to install?'
    confirminstall "$local"
  else
    local='New Update! Would you like to install?' 
    confirminstall "$local"
  fi
else
  local="We didn't find any nvim binaries in your path. Would you like to install?"
  confirminstall "$local"
fi
