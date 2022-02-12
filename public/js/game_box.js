class NotifyBox extends React.Component {
  render(){
    var content = null;

    if (typeof(this.props.notify) == 'object') {
      var button_bg_color = this.props.notify.button.bg_color || 'green';

      content = React.createElement('div', {},
        React.createElement('span', {
          className: "block sm:inline"
        },
          this.props.notify.message
        ),
        React.createElement('button', {
          onClick: this.props.notify.button.onClick,
          className: "bg-" + button_bg_color + "-600 hover:bg-" + button_bg_color + "-700 text-white font-bold px-1 mx-1 rounded"
        },
          this.props.notify.button.text
        )
      )
    }else{
      content = React.createElement('span', {
        className: "block sm:inline"
      },
        this.props.notify
      )
    }

    return React.createElement('div', {
      className: "m-2 border px-4 py-3 rounded relative text-center animation-shake",
      role: "alert"
    },
      content
    );
  }
}

class GameStatus extends React.Component {
  render(){
    var bgColorClass = this.props.status === 'online' ? 'bg-green-500' : 'bg-red-500 animate-pulse';

    return React.createElement('div', {
      className: 'flex justify-between items-center'
    },
      React.createElement('div', {
        className: 'flex justify-center'
      },
        React.createElement("svg", {
          xmlns: "http://www.w3.org/2000/svg",
          className: "mx-1 h-6 w-6 cursor-pointer",
          fill: "none",
          viewBox: "0 0 24 24",
          stroke: "gray",
        }, React.createElement("path", {
          strokeLinecap: "round",
          strokeLinejoin: "round",
          strokeWidth: 2,
          d: "M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
        })),
        React.createElement(NameModal, {
          onSubmit: this.props.onNameSubmit,
          value: this.props.player_name
        })
      ),
      React.createElement('div', {
        className: 'flex justify-center '
      },
        React.createElement('a', {
          className: 'text-xl font-bold',
          href: '/'
        },
          'WORDLE'),
        React.createElement('div', {
          className: 'w-2 h-2 rounded ' + bgColorClass,
          id: 'status'},
          '')
      ),
      React.createElement("div", {
        className: "flex justify-center"
      },
        React.createElement(MenuItem, {
          id: 'menu-copy-link',
          onClick: function(){ navigator.clipboard.writeText(window.location.href); },
          title: "Copy game link",
          afterClickTitle: "Copied to clipboard!",
          path_d: "M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1"
        }),
        React.createElement(MenuItem, {
          id: 'menu-new-game',
          onClick: function(){ document.getElementById('new_game_form').submit(); },
          title: "New game",
          path_d: "M12 4v16m8-8H4"
        })
      )
    )
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

const english_keyboard_layout = [
  ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
  ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'],
  [
    {code: 'backspace', display: '⌫', color: 'red'},
    'z', 'x', 'c', 'v', 'b', 'n', 'm',
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
    var already_matched_letters = []

    return this.props.game.attempts.reduce(function (not_found_letters, attempt) {
      var attempt_word = attempt[0];
      var attempt_match = attempt[1];

      var not_found_letters_in_word =
        attempt_match.reduce(function (not_found_letters, match, index) {
          if(match == 0) {
            not_found_letters.push(attempt_word[index]);
          }else{
            already_matched_letters.push(attempt_word[index]);
          }
          return not_found_letters;
        }, []);

      not_found_letters = not_found_letters.concat(not_found_letters_in_word);
      // TODO: made a proper fix for two letters match
      not_found_letters = not_found_letters.filter(function (letter, index) {
        return already_matched_letters.indexOf(letter) == -1;
      });
      return not_found_letters;
    }, []);
  }

  statusDescription(){
    const game_status = this.props.game.status;

    if(this.props.status != 'online'){
      return 'You are offline!';
    }

    if(game_status == 'in_progress'){
      return 'Playing...';
    }else if(game_status == 'won'){
      return 'You win!';
    }else if(game_status == 'lost'){
      return 'You definitely will win next time!';
    }
  }

  keyboardLayout(){
    if (this.props.game_language == 'ru') {
      return russian_keyboard_layout;
    } else {
      return english_keyboard_layout;
    }
  }

  render() {
    return React.createElement('div', {
      className: 'max-w-sm w-full'
    },
      React.createElement(GameStatus, {
        status: this.props.status,
        onNameSubmit: this.props.onNameSubmit,
        player_name: this.props.player_name
      }),
      React.createElement(Board, {
        game: this.props.game,
        current_word: this.state.currentWord,
        onClick: this.props.onClick,
        warning_letters: this.notFoundLetters(),
      }),
      React.createElement(NotifyBox, {
        notify: this.props.notify || this.statusDescription()
      }),
      React.createElement(Keyboard, {
        rows: this.keyboardLayout(),
        language: this.props.game_language,
        marked_buttons: this.notFoundLetters(),
        onKeyPress: this.handleCustomKeyboardPress.bind(this)
      }));
  }
}
