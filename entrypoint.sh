#!/bin/sh

set -e

#bundle check || bundle install
#yarn install --check-files

# Remove a potentially pre-existing server.pid for Rails.
rm -f /app/tmp/pids/server.pid

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
