# Use official Ruby image
FROM ruby:2.7.5-slim

# Install system dependencies
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    build-essential \
    git \
    curl \
    ca-certificates \
    redis-tools \
    && rm -rf /var/lib/apt/lists/* && \
    update-ca-certificates

# Set working directory
WORKDIR /app

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Configure bundler and install dependencies
RUN bundle config set --local without 'development test' && \
    bundle install

# Copy application code
COPY . .

# Make entrypoint script executable
RUN chmod +x docker-entrypoint.sh

# Expose port
EXPOSE 1234

# Set entrypoint
ENTRYPOINT ["./docker-entrypoint.sh"]

# Start the application
CMD ["bundle", "exec", "ruby", "app.rb"]
