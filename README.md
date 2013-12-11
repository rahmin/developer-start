# lightweight Good Eggs setup

Download and install everything you need to make a new Good Eggs machine work. Xcode not required.

## instructions

1. Update to OSX Mavericks (10.9+)
2. `xcode-select --install` to get command line tools without Xcode.
3. `curl https://raw.github.com/goodeggs/developer-start/master/setup.sh > setup.sh`
4. modify the git config username and password in the script. (or figure out how to automate this and send me a pull request!)
5. `sh ./setup.sh`
6. there is no step 6

## featuring

- [homebrew](http://brew.sh/) Friendly Mac package manager
- [homebrew-cask](https://github.com/phinze/homebrew-cask) Download, install, configure, and update GUI apps using homebrew
- [nvm](https://github.com/creationix/nvm) For multiple node.js versions
- [rbenv](https://github.com/sstephenson/rbenv) For multiple ruby versions
