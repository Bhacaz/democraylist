FROM ruby:3.0.2-alpine
RUN apk --no-cache --update add build-base nodejs tzdata postgresql-dev yarn

COPY Gemfile /app/
COPY Gemfile.lock /app/
COPY package.json /app/
COPY yarn.lock /app/

WORKDIR /app

RUN gem install foreman

COPY . /app
# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

# Configure the main process to run when running the image
CMD foreman start
#CMD bundle exec rake assets:precompile && foreman start -f Procfile
