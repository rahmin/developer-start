#!/usr/bin/env bash

# some tools will complain about not knowing where binaries are, until you do this:
echo "Making sure you have XCode command line tools..."
sudo xcode-select --install

# set up a basic .profile
if ! [ -a ~/.profile ]; then
  cat <<EOF > ~/.profile
export PATH="/usr/local/bin:\$PATH" # homebrew
export PATH="./node_modules/.bin:\$PATH" # locally installed node binaries
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
export RBENV_ROOT=/usr/local/var/rbenv # use brew's rbenv directory
if which rbenv > /dev/null; then eval "\$(rbenv init -)"; fi # rbenv shims & autocomplete
source \$(brew --prefix nvm)/nvm.sh

# for passwords and stuff:
if [ -f ~/.sekret ]; then
  source ~/.sekret
fi

EOF
fi

# install homebrew
if ! which -s brew; then
  ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go/install)"
fi
brew doctor

# install important brew packages
brew install wget git rbenv ruby-build qt nvm

# install homebrew cask and some mac os apps
brew tap phinze/homebrew-cask
brew install brew-cask
brew cask install onepassword google-chrome firefox flowdock google-hangouts

# configure git
echo "Configuring git settings:"
read -p "What name should go on your commits? " gitusername
read -p "What is your Good Eggs email address? " gituseremail
git config --global push.default simple
git config --global user.name $gitusername
git config --global user.email $gituseremail
git config --global credential.helper osxkeychain

# install nvm and node
nvm install v0.10.26
nvm alias default v0.10.26

# global node modules
npm install --global grunt-cli coffee-script

# install a ruby
rbenv install 1.9.3-p194
rbenv global 1.9.3-p194

# projects directory
mkdir ~/Projects

# Good Eggs stuff
#=================

# passwords
git clone https://github.com/goodeggs/vault ~/.goodeggs-vault
open ~/.goodeggs-vault/Good\ Eggs.agilekeychain

# set goodeggs npm registry
npm config set registry https://goodeggs.registry.nodejitsu.com/
npm config set always-auth true
npm config set strict-ssl false
echo "We're about to ask you to login to npm. Before you do this,"
echo "make sure you add yourself to the nodejitsu npm registry."
echo "(Ask another engineer if you need help with this.)"
npm login
npm cache clean

# heroku
brew install heroku

# mongo
brew install mongodb
ln -sfv /usr/local/opt/mongodb/*.plist ~/Library/LaunchAgents # load on startup
launchctl load ~/Library/LaunchAgents/homebrew.mxcl.mongodb.plist # run now

# rabbitmq
brew install rabbitmq
ln -sfv /usr/local/opt/rabbitmq/*.plist ~/Library/LaunchAgents
launchctl load ~/Library/LaunchAgents/homebrew.mxcl.rabbitmq.plist

# integration test tools
brew install phantomjs selenium-server-standalone chromedriver

# get production mongodb credentials
npm install -g dump-and-restore
read -p "Please enter the AWS access key ID for mongolabs from our 1password vault: " accesskeyid
read -p "And what is the secret access key? " secretaccesskey
cat <<EOF >> ~/.sekret
export AWS_ACCESS_KEY_ID=$accesskeyid
export AWS_SECRET_ACCESS_KEY=$secretaccesskey
EOF

# install our yeoman generator
npm install -g yo generator-goodeggs-npm

# kale
git clone https://github.com/goodeggs/kale ~/Projects/kale
cd ~/Projects/kale
npm cache clean
npm install

# garbanzo
git clone https://github.com/goodeggs/garbanzo ~/Projects/garbanzo
cd ~/Projects/garbanzo
gem install bundler
bundle install
npm install

# download data
dump-and-restore kale garbanzo
