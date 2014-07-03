#!/usr/bin/env bash

set -e
input="/dev/tty"

# set up a basic .profile
echo "Checking .profile..."
if ! [ -a ~/.profile ]; then
  cat <<EOF > ~/.profile
export PATH="/usr/local/bin:/usr/local/sbin:\$PATH" # homebrew
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
if [[ -x \$(which brew) ]]; then
  nvm_path="\$(brew --prefix nvm)/nvm.sh"
  [[ -f \$nvm_path ]] && source \$nvm_path
fi

# After nvm sets up the path
export PATH="./node_modules/.bin:\$PATH" # locally installed node binaries

# for passwords and stuff:
if [ -f ~/.sekret ]; then
  source ~/.sekret
fi

EOF
fi
source ~/.profile

# install homebrew
echo "Checking homebrew..."
if ! which -s brew; then
  # Homebrew will make sure xcode tools are installed
  ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go/install)" < $input
fi
brew doctor
mkdir -p ~/Library/LaunchAgents

# install important brew packages
brew install wget git nvm imagemagick

# source .profile once brew and nvm are setup
source ~/.profile

# install homebrew cask and some mac os apps
brew tap phinze/homebrew-cask
brew install brew-cask

brew cask install onepassword
# Open 1password so user can set up a personal vault
open /Applications/1Password\ 4.app

brew cask install google-chrome firefox flowdock google-hangouts

# heroku
brew install heroku

# mongo
(
  cd $( brew --prefix )
  git checkout 46243a1d2 Library/Formula/mongodb.rb # 2.4.8 is what we run in production
  brew install mongodb
  git checkout -- Library/Formula/mongodb.rb # restore
)
ln -sfv /usr/local/opt/mongodb/*.plist ~/Library/LaunchAgents # load on startup
launchctl load ~/Library/LaunchAgents/homebrew.mxcl.mongodb.plist # run now

# rabbitmq
brew install rabbitmq
ln -sfv /usr/local/opt/rabbitmq/*.plist ~/Library/LaunchAgents
launchctl load ~/Library/LaunchAgents/homebrew.mxcl.rabbitmq.plist

# integration test tools
brew install phantomjs selenium-server-standalone chromedriver


# configure git
echo "Configuring git settings..."
gitusername=$(git config --global user.name; exit 0) # exit 0 in case no user.name exists
gituseremail=$(git config --global user.email; exit 0) # exit 0 in case no user.name exists
if [[ -z "$gitusername" || -z "$gituseremail" ]]; then
  read -p "What name should go on your commits? " -er gitusername < $input
  read -p "What is your git email address? " -er gituseremail < $input
  git config --global push.default simple
  git config --global user.name "$gitusername"
  git config --global user.email "$gituseremail"
  git config --global credential.helper osxkeychain
fi

# install nvm and node
nvm install v0.10.26
nvm alias default v0.10.26

# global node modules
npm install --global grunt-cli coffee-script

# projects directory
echo "Checking projects..."
mkdir -p ~/Projects

# increase maximum number of open files
echo "Checking maxfile limits in launchd..."
# Run in a subshell so we don't exit on non-zero
(grep -q "^limit maxfiles" /etc/launchd.conf) &> /dev/null
if [[ $? -ne 0 ]]; then
  echo "Increasing number of maximum open files to a very high number, so node is happy..."
  sudo sh -c 'echo "limit maxfiles 1000000 1000000" >> /etc/launchd.conf'
fi

# add domains to etc/hosts
echo "Checking /etc/hosts..."
# Run in a subshell so we don't exit on non-zero
(grep -q www\.goodeggs\.dev /etc/hosts) &> /dev/null
if [[ $? -ne 0 ]]; then
  cat <<EOF | sudo tee -a /etc/hosts
127.0.0.1 admin.goodeggs.dev api.goodeggs.dev lentil.goodeggs.dev manage.goodeggs.dev ops.goodeggs.dev status.goodeggs.dev www.goodeggs.dev

EOF
fi


# Good Eggs stuff
#=================


# passwords
echo "Checking goodeggs-vault..."
if ! [ -d ~/.goodeggs-vault ]; then
  git clone https://github.com/goodeggs/vault ~/.goodeggs-vault
  open ~/.goodeggs-vault/Good\ Eggs.agilekeychain
fi

# set goodeggs npm registry
echo "Checking npm registry..."
# Run in a subshell so we don't exit on non-zero
(grep -q "^_auth =" ~/.npmrc) &> /dev/null
if [[ $? -ne 0 ]]; then
  npm config set registry https://goodeggs.registry.nodejitsu.com/
  npm config set always-auth true
  npm config set strict-ssl false
  echo "We're about to ask you to login to npm. Before you do this,"
  echo "make sure you add yourself to the nodejitsu npm registry."
  echo "(Ask another engineer if you need help with this.)"
  npm login < $input
  npm cache clean
fi

# get production mongodb credentials
echo "Checking .sekret credentials..."
if [[ ! -f ~/.sekret ]]; then
    read -p "Please enter the AWS access key ID for mongolabs from our 1password vault: " -ers AWS_ACCESS_KEY_ID < $input
    echo ""
    read -p "And what is the secret access key? " -ers AWS_SECRET_ACCESS_KEY < $input
    echo ""

    cat <<EOF > ~/.sekret
export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

EOF
fi
source ~/.sekret

# install dump-and-restore
echo "Install dump-and-restore..."
npm install -g dump-and-restore

# install our yeoman generator
echo "Install yeoman and generators..."
npm install -g yo generator-goodeggs-npm

# kale
echo "Checking kale..."
if ! [ -d ~/Projects/kale ]; then
  git clone https://github.com/goodeggs/kale ~/Projects/kale
  cd ~/Projects/kale
  npm install
fi

# lentil
echo "Checking lentil..."
if ! [ -d ~/Projects/lentil ]; then
  git clone https://github.com/goodeggs/lentil ~/Projects/lentil
  cd ~/Projects/lentil
  npm install
fi

# garbanzo
echo "Checking garbanzo..."
if ! [ -d ~/Projects/garbanzo ]; then
  git clone https://github.com/goodeggs/garbanzo ~/Projects/garbanzo
  cd ~/Projects/garbanzo
  npm install
fi

# download data
echo "Dump and restore a garbanzo db snapshot..."
dump-and-restore garbanzo

# restore kale from latest backup (shared with garbanzo)
echo "Dump and restore a kale db snapshot..."
dump-and-restore -r latest kale

# we're done!
echo "Done setting up your developer laptop! Now feel free to make it your own."
echo "We recommend restarting your machine at this point."

