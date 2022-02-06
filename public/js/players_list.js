class GamePreview extends React.Component {
  attempt_string(attempt){
    return attempt.map((value) => {
      if(value == 2){
        return String.fromCodePoint(129001); // 🟩
      } else if(value == 1){
        return String.fromCodePoint(129000);//🟨
      }else {
        return String.fromCodePoint(11036); //⬜
      }
    }).join('');
  }

  render(){
    var attempts = this.props.attempts.map(function(attempt, index){
      return React.createElement('div', {
        key: index,
        style: {
          fontFamily: 'monospace'
        }
      },
        this.attempt_string(attempt))
    }.bind(this))

    var remaining_attempts = 6 - this.props.attempts.length;
    for(var i = 0; i < remaining_attempts; i++){
      attempts.push(React.createElement('div', {
        key: i + remaining_attempts,
        style: {
          fontFamily: 'monospace'
        }
      },
        '⬜⬜⬜⬜⬜'
      ))
    }

    return React.createElement('div',
      {className: ''},
      attempts
    )
  }
}

class OnlinePlayer extends React.Component {
  render() {

    var className = 'flex flex-col items-center';

    if(this.props.winner){
      className += ' animation-win';
    }

    return React.createElement(
      'div',
      { className: className },
      React.createElement(
        'div',
        {},
        this.props.name
      ),
      React.createElement(
        GamePreview,
        { attempts: this.props.attempts },
      )
    )
  }
}

class PlayersList extends React.Component {

  render() {
    var competitors = this.props.players.filter((player) => {
      return player.id != this.props.current_player_id;
    });

    return React.createElement(
      'div',
      { className: 'my-2 grid grid-cols-3 gap-2 content-evenly justify-items-center' },

      competitors.map((player, index) =>
        React.createElement(OnlinePlayer,
          { key: index, name: player.name, attempts: player.attempts, winner: player.id == this.props.winner_id }
        )
      )
    )
  }
}
