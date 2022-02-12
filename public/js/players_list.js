class GamePreview extends React.Component {
  attempt_row(attempt, index){
    return attempt.map((value, match_index) => {
      if(value == 2){
        return React.createElement('div', {
          key: index + '-' + match_index,
          className: 'h-5 w-5 bg-green-500'
        })
      } else if(value == 1){
        return React.createElement('div', {
          key: index + '-' + match_index,
          className: 'h-5 w-5 bg-yellow-500'
        })
      }else {
        return React.createElement('div', {
          key: index + '-' + match_index,
          className: 'h-5 w-5 bg-gray-500'
        })
      }
    });
  }

  render(){
    var attempts = [];
    this.props.attempts.forEach(function(attempt, index){
      attempts = attempts.concat(this.attempt_row(attempt, index));
    }.bind(this))

    var remaining_attempts = 6 - this.props.attempts.length;
    for(var i = 0; i < remaining_attempts; i++){
      for(var j = 0; j < 5; j++){
        attempts.push(React.createElement('div', {
          key: this.props.attempts.length + i + '-' + j,
          className: 'text-center h-5 w-5 border-2'
        }))
      }
    }

    return React.createElement('div',{
      className: 'grid grid-cols-5 gap-x-0.5 gap-y-0.5 m-1'
    },
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
