# Game State Persistence

This document describes the game state persistence feature added to the Wordle multiplayer game.

## Overview

Games are now persisted to Redis, allowing game state to survive server restarts and be shared via URLs. Previously, games were only stored in memory (`$live_games` hash) and would be lost when the server restarted.

## Architecture

### Components

1. **GameRepository** (`app/game_repository.rb`)
   - Manages game persistence to Redis
   - Handles serialization/deserialization of game objects
   - Sets 24-hour expiry on game data

2. **Game Serialization** (`app/game.rb`)
   - `to_h`: Converts game state to a hash for JSON storage
   - `from_h`: Reconstructs game from stored hash
   - Preserves: word, attempts, status, dictionary name

3. **MultiplayerGame Serialization** (`app/multiplayer_game.rb`)
   - `to_h`: Converts multiplayer game state to a hash
   - `from_h`: Reconstructs multiplayer game from stored hash
   - Preserves: players, games, start/end times, winner

### Data Flow

```
1. Game Creation (/new)
   → Game object created
   → Saved to $live_games (memory cache)
   → Saved to Redis via GameRepository

2. Game Access (/games/:id)
   → Check $live_games first
   → If not in memory, load from Redis
   → Cache in memory for performance

3. Game Modifications (attempt, join, start, etc.)
   → Modify game object in memory
   → Persist changes to Redis
   → Publish updates via WebSocket
```

### Redis Keys

Games are stored with the following key pattern:
- `game:{game_id}` - Stores serialized game state as JSON

### Expiry

Games expire after 24 hours (86400 seconds) to prevent Redis from growing unbounded.

## Integration Points

The following operations now persist game state:

1. **Game creation** (`app.rb`)
2. **Simple game attempt** (`app/controllers/simple_game.rb`)
3. **Multiplayer game join** (`app/controllers/multiplayer_game.rb`)
4. **Multiplayer game start** (`app/controllers/multiplayer_game.rb`)
5. **Multiplayer game attempt** (`app/controllers/multiplayer_game.rb`)
6. **Player name update** (`app/controllers/multiplayer_game.rb`)
7. **Repeat game creation** (`app/controllers/multiplayer_game.rb`)

## Testing

### Unit Tests

- `spec/app/game_repository_spec.rb` - Tests for GameRepository
  - Game persistence
  - MultiplayerGame persistence
  - Game with winner persistence
  - Load/save/exists/delete operations

### Test Coverage

All 42 unit tests pass, including:
- Game logic tests
- MultiplayerGame logic tests
- Controller tests (with mocked repository)
- GameRepository tests

### Manual Testing

Manual tests confirmed:
- Simple game state persists correctly
- Multiplayer game state persists (players, attempts, timestamps)
- Winner state persists correctly
- Games can be accessed via shared URLs

## Usage Example

```ruby
# Create repository
repository = GameRepository.new($redis)

# Save a game
game = Game.new(dictionary, 'plain')
game.attempt('plaia')
repository.save('game_123', game)

# Load a game
loaded_game = repository.load('game_123')
# => Returns Game object with preserved state

# Check if game exists
repository.exists?('game_123')
# => true

# Delete a game
repository.delete('game_123')
```

## Benefits

1. **Persistence** - Games survive server restarts
2. **Shareability** - Users can share game URLs and others can join later
3. **Scalability** - Memory cache + Redis provides good performance
4. **Expiry** - Automatic cleanup after 24 hours prevents data bloat

## Future Improvements

Potential enhancements:
- Add game history/statistics persistence
- Store completed game results for longer periods
- Add pagination for listing user's past games
- Implement game search/filter capabilities
