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
brew install wget git
brew install imagemagick

# install homebrew cask and some mac os apps
brew tap phinze/homebrew-cask
brew install brew-cask
brew cask install onepassword google-chrome firefox flowdock google-hangouts

# configure git
echo "Configuring git settings:"
gitusername=$(git config --global user.name)
gituseremail=$(git config --global user.email)
read -t 0.1 -n 10000 # flush input from stdin
read -p "What name should go on your commits? " -ei $gitusername gitusername
read -p "What is your git email address? " -ei $gituseremail gituseremail
git config --global push.default simple
git config --global user.name $gitusername
git config --global user.email $gituseremail
git config --global credential.helper osxkeychain

# install nvm and node
source ~/.profile
nvm install v0.10.26
nvm alias default v0.10.26

# global node modules
npm install --global grunt-cli coffee-script

# projects directory
mkdir ~/Projects

# increase maximum number of open files
echo "Increasing number of maximum open files to a very high number, so node is happy..."
sudo sh -c 'echo "limit maxfiles 1000000 1000000" >> /etc/launchd.conf'

# Good Eggs stuff
#=================

# passwords
if ! [ -d ~/.goodeggs-vault ]; then
  git clone https://github.com/goodeggs/vault ~/.goodeggs-vault
  open ~/.goodeggs-vault/Good\ Eggs.agilekeychain
fi

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
read -t 0.1 -n 10000 discard # flush input from stdin
read -p "Please enter the AWS access key ID for mongolabs from our 1password vault: " -e -s AWS_ACCESS_KEY_ID
read -p "And what is the secret access key? " -e -s AWS_SECRET_ACCESS_KEY
cat <<EOF >> ~/.sekret
export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

EOF

# install dump-and-restore
npm install -g dump-and-restore

# install our yeoman generator
npm install -g yo generator-goodeggs-npm

# kale
if ! [ -d ~/Projects/kale ]; then
  git clone https://github.com/goodeggs/kale ~/Projects/kale
  cd ~/Projects/kale
  npm install
fi

# lentil
if ! [ -d ~/Projects/lentil ]; then
  git clone https://github.com/goodeggs/lentil ~/Projects/lentil
  cd ~/Projects/lentil
  npm install
fi

# garbanzo
if ! [ -d ~/Projects/garbanzo ]; then
  git clone https://github.com/goodeggs/garbanzo ~/Projects/garbanzo
  cd ~/Projects/garbanzo
  gem install bundler
  bundle install
  npm install
fi

# add domains to etc/hosts
cat <<EOF | sudo tee -a /etc/hosts
127.0.0.1 admin.goodeggs.dev lentil.goodeggs.dev manage.goodeggs.dev ops.goodeggs.dev status.goodeggs.dev www.goodeggs.dev

EOF

# download data
dump-and-restore kale garbanzo

# we're done!
echo "Done setting up your developer laptop! Now feel free to make it your own."
echo "We recommend restarting your machine at this point."

