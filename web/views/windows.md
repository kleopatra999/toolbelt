<p class="download">
  <a href="/download/windows" class="button">Heroku Toolbelt for Windows</a>
</p>

### What is it?

* [Heroku client](http://github.com/heroku/heroku) - CLI tool for creating and managing Heroku apps
* [Git](https://code.google.com/p/msysgit/) - revision control and pushing to Heroku

### Getting started

Once installed, you'll have access to the heroku command from your command shell. Log in using the email address and password you used when creating your Heroku account:

    $ heroku login
    Enter your Heroku credentials.
    Email: adam@example.com
    Password (typing will be hidden):
    Authentication successful.

You're now ready to create your first Heroku app:

    $ cd ~/myapp
    $ heroku create
    Creating stark-fog-398... done, stack is cedar-14
    http://stark-fog-398.herokuapp.com/ | https://git.heroku.com/stark-fog-398.git
    Git remote heroku added

### Technical details

The `heroku` client will be installed into `C:\Program Files\Heroku` and will be added to your `%PATH%`.
