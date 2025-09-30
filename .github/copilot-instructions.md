# Copilot Instructions for Wordle

## Project Overview

This is a multiplayer Wordle game with time competition between players. The project uses:
- **Backend**: Ruby with [Tipi web server](https://github.com/digital-fabric/tipi)
- **Frontend**: React + Tailwind CSS
- **Database**: Redis
- **Testing**: RSpec with Capybara for integration tests

## Development Setup

### Requirements
- Ruby (2.7.5)
- Redis server

### Getting Started
1. Run `bundle install` to install dependencies
2. Start Redis server
3. Prepare test database: `APP_ENV=test REDIS_URL=redis://localhost:6379/2 bundle exec ruby setup/prepare_test_db.rb`
4. Run tests: `bundle exec rspec`
5. Seed dictionaries using `setup/seed_dictionary.rb` script
6. Start server: `bundle exec tipi app.rb` (default port 1234)

## Code Style & Conventions

### Ruby
- Use `frozen_string_literal: true` at the top of Ruby files
- Follow standard Ruby naming conventions (snake_case for methods/variables)
- Keep methods focused and concise
- Use descriptive variable names

### JavaScript
- Frontend uses React with ES6 class components
- Components are stored in `public/js/`
- Use Tailwind CSS utility classes for styling
- Avoid inline styles unless necessary

### File Organization
- Application logic: `app/` directory
- Controllers: `app/controllers/`
- Game logic: `app/game.rb` and `app/multiplayer_game.rb`
- Dictionary management: `app/game/dictionary/`
- Frontend assets: `public/` directory
- Tests: `spec/` directory

## Testing Guidelines

- Write RSpec tests for all new features
- Test files mirror the application structure in `spec/`
- Use `rack-test` for controller tests
- Use Capybara with webdrivers for integration tests
- Run tests with: `bundle exec rspec`
- Test environment uses Redis database 2: `REDIS_URL=redis://localhost:6379/2`

## Architecture Notes

### Game Flow
- Games are stored in `$live_games` hash with unique IDs
- WebSocket connections handle real-time game updates
- `GameUpdatesPublisher` manages pub/sub for multiplayer games
- Two game modes: cooperative and time competition

### Dictionary System
- Words stored in Redis sets
- Separate dictionaries for English and Russian
- Two types of sets: valid guesses (`words`) and available words for solutions (`available_words`)

### Routing
- Main router in `app.rb` using Tipi routing
- Static files served from `public/`
- WebSocket handler for game interactions
- Game creation at `/new` endpoint

## Key Files

- `app.rb` - Main application and routing
- `app/game.rb` - Single player game logic
- `app/multiplayer_game.rb` - Multiplayer game logic
- `app/controllers/` - WebSocket message handlers
- `db.rb` - Redis connection setup
- `public/js/board.js` - Game board UI component
- `public/js/keyboard.js` - On-screen keyboard component

## Deployment

- Uses Mina for deployment
- Deployment config in `config/deploy.rb`
- Production server: wordle.dmitry.it
- Uses RVM for Ruby version management

## Additional Notes

- The project was originally assisted by GitHub Copilot (60-70% of frontend code)
- Supports both English and Russian dictionaries
- Real-time multiplayer using WebSockets
- Time-based competition mode for racing to solve the word
