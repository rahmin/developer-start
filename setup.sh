# FIRST:::: make sure we have Xcode command line tools.
# these can be downloaded at https://developer.apple.com/downloads
# you don't need all of Xcode!

# some tools will complain about not knowing where binaries are, until you do this:
sudo xcode-select --install

# is the following necessary? it might be.
# sudo xcode-select --switch /

# set up a basic .profile
cat <<EOF > ~/.profile
export PATH="/usr/local/bin:\$PATH" # homebrew
export PATH="./node_modules/.bin:\$PATH" # locally installed node binaries
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
export RBENV_ROOT=/usr/local/var/rbenv # use brew's rbenv directory
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi # rbenv shims & autocomplete
[ -s \$HOME/.nvm/nvm.sh ] && . \$HOME/.nvm/nvm.sh  # load nvm

EOF

# install homebrew
ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go/install)" 
brew doctor

# install important brew packages
brew install wget git rbenv ruby-build qt

# install homebrew cask and some mac os apps
brew tap phinze/homebrew-cask
brew install brew-cask
brew cask install onepassword google-chrome hipchat alfred skype caffeine
brew cask alfred link

# configure git
git config --global push.default simple
git config --global user.name "Max Edmands"
git config --global user.email "max@goodeggs.com"
git config --global credential.helper osxkeychain

# install nvm and node
curl https://raw.github.com/creationix/nvm/master/install.sh | sh
. ~/.profile
nvm install v0.10.21
nvm alias default v0.10.21

# global node modules
npm install --global grunt-cli coffee-script

# install a ruby
rbenv install 2.0.0-p247
rbenv global 2.0.0-p247

# projects directory
mkdir ~/Projects

# Good Eggs stuff
#=================

# passwords
git clone https://github.com/goodeggs/vault ~/.goodeggs-vault
open ~/.goodeggs-vault/Good\ Eggs.agilekeychain

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
npm install -g git+https://github.com/goodeggs/dump-and-restore
cat <<EOF >> ~/.profile
export AWS_ACCESS_KEY_ID=xxxx # check 1password
export AWS_SECRET_ACCESS_KEY=xxxx # check 1password
EOF

# kale
git clone https://github.com/goodeggs/kale ~/Projects/kale
cd ~/Projects/kale
npm install

# garbanzo
git clone https://github.com/goodeggs/garbanzo ~/Projects/garbanzo
cd ~/Projects/garbanzo
npm install

# download data
dump-and-restore kale garbanzo
