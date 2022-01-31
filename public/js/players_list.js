class OnlinePlayer extends React.Component {
  render() {
    var status = this.props.status || '';

    return React.createElement(
      'div',
      { className: 'online-player' },
      this.props.name + ' ' + status
    )
  }
}

class PlayersList extends React.Component {
  player_status(player) {
    if(player.id == this.props.winner_id) {
      return '🏆';
    }else if(player.id == this.props.current_player_id) {
      return '(you)';
    } else if(player.last_match) {
      return player.last_match.map((value) => {
        if(value == 2){
          return String.fromCodePoint(129001); // 🟩
        } else if(value == 1){
          return String.fromCodePoint(129000);//🟨
        }else {
          return String.fromCodePoint(11036); //⬜
        }
      }).join('');
    } else {
      return '□□□□□';
    }
  }

  render() {
    return React.createElement(
      'div',
      { className: 'px-2 py-2' },

      this.props.players.map((player, index) =>
        React.createElement(OnlinePlayer,
          { key: index, name: player.name, status: this.player_status(player) }
        )
      )
    )
  }
}
