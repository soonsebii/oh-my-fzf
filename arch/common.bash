#!/bin/bash

function error()
{
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@" >&2
}

function abs-path()
{
  cd $1; pwd; cd - >/dev/null
}

function usage()
{
  printf "usage: $0 [OPTIONS]\n"
  printf "  --d    : Verbose\n"
  printf "  --help : Show this message\n"
}

function banner()
{
  local cmd="$1"

  case "${cmd}" in
    hi)
      printf "  ___           _        _ _ \n"
      printf " |_ _|_ __  ___| |_ __ _| | |\n"
      printf "  | || '_ \/ __| __/ _v | | |\n"
      printf "  | || | | \__ \ || (_| | | |\n"
      printf " |___|_| |_|___/\__\__,_|_|_|\n"
      printf "\n"
      printf " OS: ${PLATFORM}\n"
      printf "\n"
      ;;
    bye)
      printf "\n"
      printf "  Good Bye!\n"
      printf "\n"
      ;;
  esac
}

function progress()
{
  IFS='_' read -r -a param <<< "$1"

  local func="$1"
  local name="${param[1]}"
  local spin="-\|/"

  if [[ "${OPTION_VERBOSE}" -gt 0 ]]; then
    $func &
  else
    $func 1>/dev/null 2>&1 &
  fi

  local i=0
  local pid="$!"

  while kill -0 "${pid}" 2>/dev/null
  do
    i=$(((i+1)%4))
    printf "\r[${spin:$i:1}] Update ${name}"
    sleep .1
  done

  wait "${pid}"
  if [ "$?" -eq 0 ]; then
    printf "\r[v] Update ${name}\n"
  else
    printf "\r[x] Update ${name}\n"
  fi
}

function install_fzf()
{
  if [ -z $(which fzf) ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --key-bindings --completion --update-rc
  else
    return 0;
  fi

  return "$?"
}

function update_bashrc()
{
  local abspath=$(abs-path $CWD)

  [ ! -e ~/.oh-my-fzf.bash ] && cat > ~/.oh-my-fzf.bash <<EOF
CWD=$abspath
for script_file in \$(ls \$CWD/bash/*.bash 2>/dev/null); do
    . \$script_file
done
EOF

  [ -z "$(grep 'oh-my-fzf.bash' ~/.bashrc)" ] && cat >> ~/.bashrc <<EOF
[ -f ~/.oh-my-fzf.bash ] && . ~/.oh-my-fzf.bash
EOF

  return 0;
}

function update_vimrc()
{
  local abspath=$(abs-path $CWD)

  [ -z "$(grep '\.fzf' ~/.vimrc 2>/dev/null)" ] && cat >> ~/.vimrc <<EOF
set rtp+=~/.fzf
EOF

  [ -z "$(grep ${abspath} ~/.vimrc 2>/dev/null)" ] && cat >> ~/.vimrc <<EOF
set rtp+=${abspath}
EOF

  return 0;
}

function update_tmux()
{
  local abspath=$(abs-path $CWD)

  if [ "$PLATFORM" == "Darwin" ]; then
    cp $abspath/plugin/tmux.conf ~/.tmux.conf
  else
    tmux source-file $abspath/plugin/tmux.conf
    [ "$?" -gt 0 ] && cp $abspath/plugin/tmux.conf ~/.tmux.conf
  fi

  return 0;
}

function os_name()
{
  if [ -f /etc/os-release ]; then
    cat /etc/os-release | egrep "^ID=" | sed "s/ID=//g"
  elif [ -f /etc/lsb-release ]; then
    cat /etc/lsb-release | egrep "^DISTRIB_ID=" | sed "s/DISTRIB_ID=//g"
  elif [ -f /etc/centos-release ]; then
    cat /etc/centos-release | awk '{print $1}' | tr "[:upper:]" "[:lower:]"
  else
    echo "unknown"
  fi
}

function os_version()
{
  if [ -f /etc/os-release ]; then
    cat /etc/os-release | egrep "^VERSION_ID=" | sed "s/VERSION_ID=//g"
  elif [ -f /etc/lsb-release ]; then
    cat /etc/lsb-release | egrep "^DISTRIB_RELEASE=" | sed "s/DISTRIB_RELEASE=//g"
  else
    echo "unknown"
  fi
}
