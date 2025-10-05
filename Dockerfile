# Use official Ruby image
FROM ruby:2.7.5-slim

# Install system dependencies
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    build-essential \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install Ruby dependencies
RUN bundle install --without development test

# Copy application code
COPY . .

# Expose port
EXPOSE 1234

# Start the application
CMD ["bundle", "exec", "ruby", "app.rb"]
