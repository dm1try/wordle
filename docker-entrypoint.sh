#!/bin/bash
set -e

# Wait for Redis to be ready
echo "Waiting for Redis..."
until redis-cli -h redis ping > /dev/null 2>&1; do
  echo "Redis is unavailable - sleeping"
  sleep 1
done
echo "Redis is up!"

# Only initialize dictionaries and show startup message when running the default app command
# Skip for bash, sh, or any command that starts with APP_ENV=test
if [ "$#" -eq 0 ] || ([ "$1" = "bundle" ] && [ "$2" = "exec" ] && [ "$3" = "ruby" ] && [ "$4" = "app.rb" ]); then
  echo "Initializing dictionaries..."
  bundle exec ruby setup/init_dictionaries.rb
  echo "Starting Wordle application..."
  exec bundle exec ruby app.rb
else
  # For all other commands (tests, bash, etc.), just execute them
  exec "$@"
fi
