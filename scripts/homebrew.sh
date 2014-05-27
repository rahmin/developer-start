#!/usr/bin/env bash

# install homebrew
if ! which -s brew; then
  ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go/install)"
fi
brew doctor
