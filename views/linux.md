### Heroku Toolbelt for Debian/Ubuntu

<pre><code>sudo -s # or su if you prefer
echo "deb http://toolbelt.herokuapp.com/ubuntu ./" > /etc/apt/sources.list.d/heroku.list
wget -q -O - http://toolbelt.herokuapp.com/apt/release.key | apt-key add -
apt-get update
apt-get install heroku-toolbelt</code></pre>