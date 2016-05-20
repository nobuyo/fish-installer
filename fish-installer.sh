#!/bin/bash
#
# fish-installer
#   install fish locally without sudo/root
#

INSTALL_DIR=${INSTALL_DIR:-"$HOME/local"}
WORK_SPACE=${WORK_SPACE:-"/tmp/fish-installer"}
LOGFILE="$WORK_SPACE/install.log"

package_fish="https://github.com/fish-shell/fish-shell/releases/download/2.2.0/fish-2.2.0.tar.gz"
package_gcc="http://ftp.tsukuba.wide.ad.jp/software/gcc/releases/gcc-5.3.0/gcc-5.3.0.tar.gz"

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

function show_result {
  case "$1" in
  0 )
    success "installed $2 to $INSTALL_DIR"
    ;;
  * )
    error "failed install $2 with $1, see $LOGFILE to more info"
    ;;
  esac
}

function download {
  case "$1" in
    "-O" )
      wget "$@" &>/dev/null &&
      success "download source file: $2"
      ;;
    * )
      wget "$1" &>/dev/null &&
      success "download source file: $(basename -- $1)"
      ;;
  esac
}

function check_available {
  which "$1" &>/dev/null
  return $?
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

function clean {
  rm -rf /tmp/fish-installer/*
}

function install_gcc {
  local result=1
  local tar_package="$(basename $package_gcc)"
  local package="${tar_package%.tar.gz}"
  cd "$WORK_SPACE"
  download "$package_gcc"
  echo "installing gcc-5.3.0..."
  {
    echo "=========INSTALLING GCC=========" &&
    md5sum "$tar_package" &&
    tar zxf "$tar_package" &&
    cd "$package" &&
    ./contrib/download_prerequisites
    mkdir build &&
    cd build &&
    ../configure --prefix="$INSTALL_DIR" --disable-multilib --disable-bootstrap&&
    make &&
    make install
    result=$?
  } > "$WORK_SPACE/tmp.$$" 2>&1
  cat "$WORK_SPACE/tmp.$$" >> "$LOGFILE"
  show_result "$result" "gcc"
}

function install_fish {
  local result=1
  local tar_package="$(basename $package_fish)"
  local package="${tar_package%.tar.gz}"
  cd "$WORK_SPACE"
  download "$package_fish"
  echo "installing fish-2.2.0..."
  {
    echo "=========INSTALLING FISH=========" &&
    md5sum "$tar_package" &&
    tar zxf "$tar_package" &&
    cd "$package" &&
    ./configure --prefix="$INSTALL_DIR" &&
    make &&
    make install
    result=$?
  } > "$WORK_SPACE/tmp.$$" 2>&1
  cat "$WORK_SPACE/tmp.$$" >> "$LOGFILE"
  show_result "$result" "fish"
}


function install {
  check_os
  mkdir -p "$INSTALL_DIR"
  mkdir -p "$WORK_SPACE"
  export CPPFLAGS="-I$INSTALL_DIR/include" LDFLAGS="-L$INSTALL_DIR/lib" LD_LIBRARY_PATH="$INSTALL_DIR/lib"
  echo "fish-installer $(date)" > "$LOGFILE"
  check_available "g++" || 
  install_gcc
  install_fish
}

# clean
install

