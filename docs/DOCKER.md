# Docker Setup for Wordle

This document explains how to use Docker for development and production deployment of the Wordle multiplayer game.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Development Setup](#development-setup)
- [Production Deployment](#production-deployment)
- [Architecture](#architecture)
- [Troubleshooting](#troubleshooting)

## Prerequisites

- Docker (version 20.10 or later)
- Docker Compose (version 2.0 or later)

To check if you have Docker installed:
```bash
docker --version
docker compose version
```

## Development Setup

### Quick Start

The development setup uses `docker-compose.yml` which includes:
- Redis service for data storage
- Application service with hot-reloading
- Volume mounts for live code editing
- Automatic dictionary initialization

To start the development environment:

```bash
# Clone the repository
git clone https://github.com/dm1try/wordle.git
cd wordle

# Start all services
docker compose up
```

The application will be available at http://localhost:1234

### Development Features

1. **Live Code Reload**: Changes to the code are reflected immediately (volume mount)
2. **Automatic Dictionary Initialization**: On first run, starter dictionaries are populated
3. **Persistent Redis Data**: Redis data is preserved across container restarts

### Running Tests

```bash
# Run all tests
docker compose run --rm app bash -c "APP_ENV=test REDIS_URL=redis://redis:6379/2 bundle exec ruby setup/prepare_test_db.rb && bundle exec rspec"

# Run specific test file
docker compose run --rm app bash -c "APP_ENV=test REDIS_URL=redis://redis:6379/2 bundle exec rspec spec/app_spec.rb"
```

### Accessing Redis CLI

```bash
docker compose exec redis redis-cli
```

### Adding More Dictionary Words

The initial setup includes only starter words. To populate full dictionaries:

```bash
# Access the app container
docker compose exec app bash

# Use the seed_dictionary script
bundle exec ruby setup/seed_dictionary.rb "https://example.com/wordlist" "css-selector" "dictionary_name"
```

### Stopping the Development Environment

```bash
# Stop services (preserves data)
docker compose stop

# Stop and remove containers (preserves volumes)
docker compose down

# Stop and remove everything including volumes (DANGER: deletes all data)
docker compose down -v
```

## Production Deployment

### Using Docker Compose (Recommended)

The production setup uses `docker-compose.prod.yml` which includes:
- Redis service with automatic restart
- Application service with automatic restart
- No volume mounts (code is baked into the image)
- Optimized health checks

```bash
# Build and start in production mode
docker compose -f docker-compose.prod.yml up -d --build

# View logs
docker compose -f docker-compose.prod.yml logs -f

# Stop services
docker compose -f docker-compose.prod.yml down
```

### Using Standalone Docker

If you prefer to use Docker without Compose:

```bash
# Build the image
docker build -t wordle:latest .

# Run Redis
docker run -d --name wordle-redis redis:7-alpine

# Run the application
docker run -d \
  --name wordle-app \
  -p 1234:1234 \
  -e REDIS_URL=redis://wordle-redis:6379 \
  --link wordle-redis:redis \
  wordle:latest
```

### Environment Variables

The following environment variables can be configured:

- `REDIS_URL` - Redis connection URL (default: `redis://redis:6379`)
- `PORT` - Application port (default: `1234`)
- `APP_ENV` - Application environment (`development`, `test`, `production`)

Example:
```bash
docker run -e REDIS_URL=redis://my-redis:6379 -e PORT=8080 wordle:latest
```

### Deploying to Cloud Platforms

#### Docker Hub

```bash
# Tag the image
docker tag wordle:latest yourusername/wordle:latest

# Push to Docker Hub
docker push yourusername/wordle:latest

# Pull and run on production server
docker pull yourusername/wordle:latest
docker compose -f docker-compose.prod.yml up -d
```

#### Using with Reverse Proxy (nginx)

Example nginx configuration:

```nginx
server {
    listen 80;
    server_name wordle.example.com;

    location / {
        proxy_pass http://localhost:1234;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

## Architecture

### Services

1. **Redis** (`redis:7-alpine`)
   - Stores game state and dictionaries
   - Persistent volume for data
   - Health checks ensure availability

2. **Application** (Ruby 2.7.5)
   - Iodine web server
   - WebSocket support for multiplayer
   - Automatic dictionary initialization

### Docker Images

- **Base Image**: `ruby:2.7.5-slim`
- **Final Image Size**: ~350-400MB (optimized with slim base)

### Volumes

Development:
- `redis_data`: Persistent Redis data
- `bundle_cache`: Cached Ruby gems
- `.:/app`: Source code mount for live editing

Production:
- `redis_data`: Persistent Redis data only

### Initialization Process

The `docker-entrypoint.sh` script:
1. Waits for Redis to be healthy
2. Runs `init_dictionaries.rb` to populate starter words
3. Starts the application

## Troubleshooting

### Problem: Application won't start

**Solution**: Check if Redis is running
```bash
docker compose ps
docker compose logs redis
```

### Problem: Dictionaries are empty

**Solution**: Run the initialization script manually
```bash
docker compose exec app bundle exec ruby setup/init_dictionaries.rb
```

### Problem: Port 1234 already in use

**Solution**: Change the port in docker-compose.yml
```yaml
ports:
  - "8080:1234"  # Use port 8080 instead
```

### Problem: Changes not reflecting in development

**Solution**: Restart the application container
```bash
docker compose restart app
```

### Problem: Out of disk space

**Solution**: Clean up Docker resources
```bash
# Remove unused containers, networks, and images
docker system prune -a

# Remove unused volumes
docker volume prune
```

### Problem: SSL certificate errors during build

This can happen in CI/CD environments. The production Dockerfile is correctly configured with CA certificates. If you encounter this locally, ensure your system time is correct and you have a stable internet connection.

## Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Iodine Web Server](https://github.com/boazsegev/iodine)
- [Redis Documentation](https://redis.io/documentation)

## Contributing

When adding new features that require environment changes:
1. Update the Dockerfile if new system dependencies are needed
2. Update docker-compose.yml for development configuration
3. Update docker-compose.prod.yml for production configuration
4. Update this documentation with any new setup steps
