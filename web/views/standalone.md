<p class="download">
    <code><span>wget -qO- <a href="/install.sh">https://toolbelt.heroku.com/install.sh</a> | sh</span></code>
</p>

### What is it?

* [Heroku client](http://github.com/heroku/heroku) - CLI tool for creating and managing Heroku apps

### Getting started

Once installed, you'll have access to the heroku command from your command shell. Log in using the email address and password you used when creating your Heroku account:

    $ heroku login
    Enter your Heroku credentials.
    Email: adam@example.com
    Password:
    Could not find an existing public key.
    Would you like to generate one? [Yn]
    Generating new SSH public key.
    Uploading ssh public key /Users/adam/.ssh/id_rsa.pub

You're now ready to create your first Heroku app:

    $ cd ~/myapp
    $ heroku create
    Creating stark-fog-398... done, stack is cedar
    http://stark-fog-398.herokuapp.com/ | git@heroku.com:stark-fog-398.git
    Git remote heroku added

### Technical details

The install script will download a tarball of the `heroku` client and install it to `/usr/local/heroku`.
