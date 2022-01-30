class NotifyBox extends React.Component {
  render(){
    return React.createElement('div', {
      className: "m-2 border px-4 py-3 rounded relative text-center",
      role: "alert"
    },
      React.createElement('span', {
        className: "block sm:inline"
      },
        this.props.message ||  "Loading..."
      )
    );
  }
}

class GameStatus extends React.Component {
  render(){
    var bgColorClass = this.props.status === 'online' ? 'bg-green-500' : 'bg-red-500 animate-pulse';

    return React.createElement('div', {
      className: 'flex justify-center'
    },
      React.createElement('div', {
        className: 'text-xl font-bold'
      },
        'WORDLE'),
      React.createElement('div', {
        className: 'w-2 h-2 rounded ' + bgColorClass,
        id: 'status'},
        '')
    );
  }
}

const russian_keyboard_layout = [
  ['й', 'ц', 'у', 'к', 'е', 'н', 'г', 'ш', 'щ', 'з', 'х', 'ъ'],
  ['ф', 'ы', 'в', 'а', 'п', 'р', 'о', 'л', 'д', 'ж', 'э'],
  [
    {code: 'backspace', display: '⌫', color: 'red'},
    'я', 'ч', 'с', 'м', 'и', 'т', 'ь', 'б', 'ю',
    { code: 'enter', display: '⏎', color: 'green' }
  ]
];

class GameBox extends React.Component {
  constructor(props){
    super(props);
    this.state = {
      currentWord: '',
      not_found_letters: [],
    };
  }

  componentDidMount(){
    document.addEventListener('keyup', this.handleKeyUp.bind(this));
  }

  handleKeyUp(event){
    if (event.keyCode === 13) {
      this.props.onWordSubmit(this.state.currentWord);
      this.setState({ currentWord: '' });
    } else if(event.keyCode === 8) {
      this.setState(function(prevState, props){
        return { currentWord: prevState.currentWord.slice(0, -1) };
      });
    }else{
      var lowercased_key = event.key.toLowerCase();
      if(this.state.currentWord.length < 5 && lowercased_key.length == 1 && (lowercased_key.match(/[a-z]/g) || lowercased_key.match(/[а-я]/g))){
        this.setState(function(prevState, props){
          return { currentWord: prevState.currentWord + lowercased_key };
        });
      }
    }
  }

  handleCustomKeyboardPress(key){
    if(key == 'backspace') {
      this.setState(function(prevState, props){
        return { currentWord: prevState.currentWord.slice(0, -1) };
      });
    }else if(key == 'enter') {
      this.props.onWordSubmit(this.state.currentWord);
      this.setState({ currentWord: '' });
    }else{
      if(this.state.currentWord.length < 5) {
        this.setState(function(prevState, props){
          return { currentWord: prevState.currentWord + key };
        });
      }
    }
  }

  notFoundLetters(){
    return this.props.game.attempts.reduce(function (not_found_letters, attempt) {
      var attempt_word = attempt[0];
      var attempt_match = attempt[1];

      var not_found_letters_in_word =
        attempt_match.reduce(function (not_found_letters, match, index) {
          if(match == 0) {
            not_found_letters.push(attempt_word[index]);
          }
          return not_found_letters;
        }, []);

      not_found_letters = not_found_letters.concat(not_found_letters_in_word);
      return not_found_letters;
    }, []);
  }

  statusDescription(){
    const game_status = this.props.game.status;

    if(game_status == 'in_progress'){
      return 'Playing...';
    }else if(game_status == 'won'){
      return 'You win!';
    }else if(game_status == 'lost'){
      return 'You definitely will win next time!';
    }
  }

  render() {
    return React.createElement('div', {
      className: 'max-w-sm w-full'
    },
      React.createElement(GameStatus, {
        status: this.props.status,
      }),
      React.createElement(Board, {
        attempts: this.props.game.attempts,
        current_word: this.state.currentWord,
        onClick: this.props.onClick
      }),
      React.createElement(NotifyBox, {
        message: this.props.notify_message || this.statusDescription()
      }),
      React.createElement(Keyboard, {
        rows: russian_keyboard_layout,
        marked_buttons: this.notFoundLetters(),
        onKeyPress: this.handleCustomKeyboardPress.bind(this)
      }));
  }
}
