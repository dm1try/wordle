#!/bin/bash
set -e

# Wait for Redis to be ready
echo "Waiting for Redis..."
until redis-cli -h redis ping > /dev/null 2>&1; do
  echo "Redis is unavailable - sleeping"
  sleep 1
done
echo "Redis is up!"

# Initialize dictionaries if not already done
echo "Initializing dictionaries..."
bundle exec ruby setup/init_dictionaries.rb

# Start the application
echo "Starting Wordle application..."
exec "$@"
