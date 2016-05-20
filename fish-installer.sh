#!/bin/bash
#
# fish-installer
#   install fish locally without sudo/root
#

INSTALL_DIR=${INSTALL_DIR:-"$HOME/local"}
WORK_SPACE=${WORK_SPACE:-"/tmp/fish-installer"}
LOGFILE="$WORK_SPACE/install.log"
FISH_SOURCE="https://github.com/fish-shell/fish-shell/releases/download/2.2.0/fish-2.2.0.tar.gz"

function warn {
  # color:yellow
  echo -e "\033[33mWarning\033[m" "$*"
}

function error {
  # color:red
  echo -e "\033[31mError\033[m" "$*"
}

function success {
  # color:green
  echo -e "\033[32mSuccess\033[m" "$*"
}

function download {
  if which curl &>/dev/null; then
    curl -L $@
  elif which wget &>/dev/null; then
    wget -O - $@
  fi
}

function check_os {
  case ${OSTYPE} in
  linux* )
    success "The system is $OSTYPE, ready to deploy"
    ;;
  * )
    error "$OSTYPE is NOT supported, exitting"
    exit 1
    ;;
  esac
}

function install {
  local tar_package="$(basename $FISH_SOURCE)"
  local package="${tar_package%.tar.gz}"
  mkdir "$WORK_SPACE"
  cd "$WORK_SPACE"
  echo "prepareing file..."
  download "$FISH_SOURCE" | tar zxf "$tar_package" && 
  success "download file $tar_package"

  cd $package &&
  ./configure --prefix="$INSTALL_DIR" &&
  make &&
  make install
}

check_os
install

