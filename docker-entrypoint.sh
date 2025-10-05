#!/bin/bash
set -e

# Wait for Redis to be ready
echo "Waiting for Redis..."
until redis-cli -h redis ping > /dev/null 2>&1; do
  echo "Redis is unavailable - sleeping"
  sleep 1
done
echo "Redis is up!"

# Initialize dictionaries only if starting the app (not for tests or other commands)
if [ "$1" = "bundle" ] && [ "$2" = "exec" ] && [ "$3" = "ruby" ] && [ "$4" = "app.rb" ]; then
  echo "Initializing dictionaries..."
  bundle exec ruby setup/init_dictionaries.rb
  echo "Starting Wordle application..."
fi

exec "$@"
