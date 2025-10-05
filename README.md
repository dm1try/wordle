# wordle

Multiplayer wordle

In addition to the original rules there is a time competition beetween players in the game.
The faster one wins.

![image](wwwordle.png)
## Demo

https://wordle.dmitry.it

## Acknowledgements

[Wordle](https://www.nytimes.com/games/wordle/index.html) is an original idea. 
[Copilot](https://copilot.github.com) is the best pair programmer ever! It wrote 60-70% of frontend code :)


## Development
Backend: [Iodine](https://github.com/boazsegev/iodine), Frontend: [React](https://github.com/facebook/react) + [Tailwind CSS](https://github.com/tailwindlabs/tailwindcss)

### Using Docker (Recommended)

The easiest way to get started is using Docker. For detailed Docker documentation, see [docs/DOCKER.md](docs/DOCKER.md).

**Requirements:**
- Docker
- Docker Compose

**Quick Start:**
```bash
# Clone the repository
git clone https://github.com/dm1try/wordle.git
cd wordle

# Start the application with docker compose
docker compose up

# Or use the Makefile for convenience
make up
```

The first run will:
- Build the Docker image
- Start Redis
- Install dependencies
- Initialize dictionaries with starter words
- Start the application on http://localhost:1234

**Using Makefile (Optional):**
A Makefile is provided for convenience:
```bash
make help          # Show all available commands
make up            # Start development environment
make up-d          # Start in background
make down          # Stop services
make logs          # View logs
make test          # Run tests
make shell         # Access app container
make redis-cli     # Access Redis CLI
make clean         # Clean up everything
```

**Run tests:**
```bash
docker compose run --rm app bash -c "APP_ENV=test REDIS_URL=redis://redis:6379/2 bundle exec ruby setup/prepare_test_db.rb && bundle exec rspec"
```

**Seed full dictionaries:**
The initial setup includes only starter words. To populate full dictionaries from the internet:
```bash
# For English words
docker compose run --rm app bundle exec ruby setup/seed_dictionary.rb "https://example.com/wordlist" "css-selector" "words_en"

# For Russian words  
docker compose run --rm app bundle exec ruby setup/seed_dictionary.rb "https://example.com/wordlist" "css-selector" "words"
```

**Production deployment:**
```bash
# Using docker-compose.prod.yml
docker compose -f docker-compose.prod.yml up -d

# Or using standalone Docker
docker build -t wordle .
docker run -d -p 1234:1234 -e REDIS_URL=redis://your-redis-host:6379 wordle
```

### Manual Setup (Without Docker)

Requirements:
 - ruby (2.7.5)
 - redis

0. clone repo
1. run `bundle install` in source directory
2. run the tests by using this command `APP_ENV=test REDIS_URL=redis://localhost:6379/2 bundle exec ruby setup/prepare_test_db.rb && bundle exec rspec`

3. fill the dictionaries if all the above steps have been completed successfully
  ```
  redis-cli
  127.0.0.1:6379> SADD words_en plain
  127.0.0.1:6379> SADD available_words_en plain 
  ```
  **Dictionary Sets Explanation:**
  - `words_en` - contains words that can be used as solutions (the word the player needs to guess)
  - `available_words_en` - contains all valid words that can be used for guessing attempts (for validation)
  
  The same applies to other language dictionaries (e.g., `words` and `available_words` for Russian).

Also, use the setup scripts to populate dictionaries with words [from internet](https://github.com/dm1try/wordle/blob/a9d0babd0711d39ad8fc3f4f9bf8ee9efaa5622a/setup/seed_dictionary.rb#L1-L2).

4. run application locally with `bundle exec ruby app.rb`
