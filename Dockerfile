FROM ubuntu:14.04
MAINTAINER Jeff Dickey <jeff@heroku.com>

RUN apt-get update
RUN apt-get install -y build-essential git ruby ruby-dev libpq-dev libsqlite3-dev
RUN gem install bundler
RUN git clone --recursive https://github.com/heroku/toolbelt ~/toolbelt
RUN bundle install --gemfile ~/toolbelt/Gemfile
RUN bundle install --gemfile ~/toolbelt/components/foreman/Gemfile
RUN bundle install --gemfile ~/toolbelt/components/heroku/Gemfile
RUN rm -rf ~/toolbelt

ADD ./dist/resources/deb/build ./build
CMD ./build
