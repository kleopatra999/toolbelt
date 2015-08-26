[![Build Status](https://travis-ci.org/heroku/toolbelt.svg?branch=master)](https://travis-ci.org/heroku/toolbelt)

# Heroku Toolbelt

The Heroku Toolbelt is a package of the Heroku CLI, Foreman, and Git —
all the tools you need to get started using Heroku at the command
line. The Toolbelt is available as a native installer for OS X and
Windows, and is available from an apt-get repository for Debian/Ubuntu
Linux.

This repository is a static site with instructions and downloads for
the toolbelt packages.

# Setup

The toolbelt stores download statistics in Postgres:

    $ initdb pg
    $ postgres -D pg # in a separate terminal
    $ createdb toolbelt
    $ cat toolbelt.sql | psql toolbelt

Run `bundle exec rake` to run the site's test suite.

# Publishing Updates

[Toolbelt releases are now done inside the CLI repo.](https://github.com/heroku/heroku/blob/master/RELEASE.md)

# License

The MIT License (MIT)

Copyright © Heroku 2008 - 2015

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
