# add heroku repository to apt
echo "deb http://toolbelt.herokuapp.com/ubuntu ./" > /etc/apt/sources.list.d/heroku.list

# install heroku's release key for package verification
wget -q -O - http://toolbelt.herokuapp.com/apt/release.key | apt-key add -

# update your sources
apt-get update

# install the toolbelt
apt-get install heroku-toolbelt
