FROM ruby:3.0.2-alpine
RUN apk --no-cache --update add build-base nodejs tzdata postgresql-dev yarn
WORKDIR /app
COPY Gemfile Gemfile.lock package.json yarn.lock /app/
COPY Gemfile.lock /app/
COPY package.json /app/
COPY yarn.lock /app/

WORKDIR /app

RUN bundle check || bundle install
RUN yarn install --check-files

COPY . /app
# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
#EXPOSE 3000

# Configure the main process to run when running the image
CMD ["rails", "server", "-b", "0.0.0.0"]
