FROM ruby:3.0.2-alpine
RUN apk --no-cache --update add build-base nodejs tzdata postgresql-dev yarn

COPY Gemfile /app/
COPY Gemfile.lock /app/
COPY package.json /app/
COPY yarn.lock /app/

WORKDIR /app

ENV RAILS_ENV=production
ENV NODE_ENV=production

RUN gem install foreman
RUN bundle config set --local without 'development test'
RUN bundle check || bundle install
RUN yarn install --check-files

COPY . /app
# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

# set dummy SECRET_KEY_BASE
RUN SECRET_KEY_BASE=1 bundle exec rake assets:precompile
RUN rm -fr node_modules tmp/cache

# Configure the main process to run when running the image
CMD foreman start
