[![Build Status](https://travis-ci.org/heroku/toolbelt.png)](https://travis-ci.org/heroku/toolbelt)

# Heroku Toolbelt

The Heroku Toolbelt is a package of the Heroku CLI, Foreman, and Git —
all the tools you need to get started using Heroku at the command
line. The Toolbelt is available as a native installer for OS X and
Windows, and is available from an apt-get repository for Debian/Ubuntu
Linux.

This repository serves two purposes: 0) a static site with
instructions and downloads for the toolbelt packages and 1) tasks
to perform the packaging itself. The `bin/web` script will launch the
web site, while the packaging is handled with rake.

# Setup

The toolbelt stores download statistics in Postgres:

    $ initdb pg
    $ postgres -D pg # in a separate terminal
    $ createdb toolbelt
    $ cat toolbelt.sql | psql toolbelt

The toolbelt site uses `heroku-bouncer` to synchronize the session with different Heroku properties and track the page visits. In order to do so, [set your app as an OAuth client](https://github.com/heroku/heroku-bouncer#use) and add a custom `SESSION_SECRET` env. var.

Run `bundle exec rake` to run the site's test suite.

# Publishing Updates

To publish a new version of Foreman or the Heroku client, simply
update the git submodule under the `components/` directory and
initiate a build of the `toolbelt-build` job in Jenkins. Note that the
version of the Toolbelt is locked to the version of the Heroku client;
it is currently impossible to cut a new release of the Toolbelt
without a corresponding bump to the Heroku client version number.

# Packaging

First pull in the dependencies with bundler, then pull in the
submodules for `foreman` and the `heroku` CLI client repositories:

    $ bundle install
    $ git submodule update --init --recursive

The packaging tasks vary by platform:

    $ bundle exec rake deb:build # build the apt-get repository
    $ bundle exec rake pkg:build # build an OS X .pkg file
    $ bundle exec rake exe:build # build an .exe file for Windows

Each one has a corresponding `*:release` task which also pushes the
artifacts up to S3. This requires the `HEROKU_RELEASE_ACCESS` and
`HEROKU_RELEASE_SECRET` environment variables to be set to the proper
AWS credentials.

## Windows Packaging

The Windows installer can be built on the Mac and Linux using Wine.

You'll need wine. On the Mac you'll also need winetricks and XQuartz.

### Installing Mac prerequisites

* Install [XQuartz](http://xquartz.macosforge.org/) manually, or via the terminal:

        curl -O# http://xquartz-dl.macosforge.org/SL/XQuartz-2.7.6.dmg
        hdiutil attach XQuartz-2.7.6.dmg -mountpoint /Volumes/xquartz
        sudo installer -store -pkg /Volumes/xquartz/XQuartz.pkg -target /
        hdiutil detach /Volumes/xquartz
        rm XQuartz-2.7.6.dmg

  You must reboot after installing XQuartz.

* Install wine and winetricks:

        brew install wine
        brew install winetricks

### General setup

The certificate and private key for code signing are in the repo in:

> dist/resources/exe/heroku-codesign-cert*

which is in the format mono signcode wants.

The pvk file is encrypted. If you want the build not to prompt you for
its passphrase, you'll need to decrypt it. See the `exe:pvk-nocrypt` task.

Bewake the openssl version on the Mac doesn't work with `exe:pvk-nocrypt`.
See comments on the source code for details and solution.

If you wanna leave the key encrypted, you still have to link it before
building; run the `exe:pvk` task for that.

You'll have to ask the right person for the passphrase to the key.

You then need to initialize a custom wine build environment. The `exe:init-wine`
task will do that for you.

That's all, then just run `exe:build`.


## Ruby versions

Toolbelt bundles Ruby using different sources according to the OS:

- Windows: fetches [rubyinstaller.exe](http://rubyinstaller.org/) from S3.
- Mac: fetches ruby.pkg from S3. That file was extracted from
[RailsInstaller](http://railsinstaller.org/en).
- Linux: uses system debs for Ruby (requires Ruby 1.9+).


## Beta versions

In order to test packaging new Ruby versions or change the way builds happen,
it's possible to build beta versions of the Toolbelt, leaving the original
files untouched.

To do so, release a `pre` version of the heroku gem (eg: version it `1.2.3.pre`).
Then, in the toolbelt repo, update the submodule `components/heroku` to match
that version, and push it in a branch (eg: `toolbelt-beta`). Now when you request
Jenkins to build this branch Toolbelt will generate `heroku-toolbelt-beta`
instead, leaving the original file untouched.


# License

The MIT License (MIT)

Copyright © Heroku 2008 - 2013

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
