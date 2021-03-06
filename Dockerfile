FROM ruby:2.5-stretch

RUN apt-get update -qq
# Add https support to apt to download yarn & node
RUN apt install -y apt-transport-https

# Add basic dev tools
RUN apt install -y curl build-essential wget git

# Add node and yarn repos and install them along
# along with other rails deps
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update -qq

# Install system dependencies
RUN apt-get update -qq && apt install -y --no-install-recommends postgresql-client build-essential libpq-dev nodejs yarn imagemagick libreoffice ffmpeg unzip clamav clamav-freshclam clamav-daemon openjdk-8-jre-headless

# Chrome 74
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list
RUN apt-get update && apt-get -y install google-chrome-stable

# Chromedriver
RUN wget -q https://chromedriver.storage.googleapis.com/74.0.3729.6/chromedriver_linux64.zip
RUN unzip chromedriver_linux64.zip -d /usr/local/bin
RUN rm -f chromedriver_linux64.zip

# Install Ruby Gems
RUN gem install bundler
ENV BUNDLE_PATH /usr/local/bundle
WORKDIR /ucla2019
COPY Gemfile /ucla2019/Gemfile
COPY Gemfile.lock /ucla2019/Gemfile.lock
RUN bundle install

# Update AV
RUN freshclam
RUN /etc/init.d/clamav-daemon start &

# Install fits
RUN mkdir /fits
WORKDIR /fits
ADD https://github.com/harvard-lts/fits/releases/download/1.4.0/fits-1.4.0.zip /fits/
RUN unzip fits-1.4.0.zip -d /fits
ENV PATH "/fits:$PATH"

# Add ucla2019
COPY / /ucla2019
CMD ["sh", "/ucla2019/docker/start-app.sh"]
