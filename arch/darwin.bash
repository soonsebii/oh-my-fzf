#!/bin/bash

function __require()
{
  if [ -z $(which brew) ]; then
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  else
    return 0;
  fi

  return "$?"
}

function install_git()
{
  __require

  if [ -z $(which git) ]; then
    brew install git
  else
    return 0;
  fi

  return "$?"
}

function install_moreutils()
{
  __require

  [ -z $(which ifne) ] && brew install moreutils
  [ -z $(which tmux) ] && brew install tmux
}

function install_ag()
{
  __require

  [ -z $(which ag) ] && brew install the_silver_searcher
}

