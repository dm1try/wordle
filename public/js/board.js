class WordLetter extends React.Component {
  render(){
    var className =  'text-center text-4xl leading-relaxed h-16 text-extrabold uppercase';

    if (this.props.match == 1) {
      className += ' bg-yellow-500 text-white';
    } else if(this.props.match == 2) {
      className += ' bg-green-500 text-white';
    } else if(this.props.match == 0) {
      className += ' bg-gray-500 text-white';
    } else if(this.props.match == 4) {
      className += ' border-2 border-red-300';
    }else {
      className += ' border-2';
    }

    if(this.props.pressed) {
      className += ' animation-press'
    }

    return  React.createElement(
      'div',
      { className: className},
      this.props.letter
    );
  }
}

class WordGuess extends React.Component {
  render() {
    var word_len = this.props.word.length;

    var letters = this.props.word.split('').map((letter, index) => {
      return    React.createElement(
        WordLetter,
        { key: index, letter: letter, match: this.props.matches[index], pressed: (index == word_len - 1) }
      )
    });

    for(var i = 0; i < (5 - this.props.word.length); i++) {
      letters.push(React.createElement(
        WordLetter,
        { key: i+100, letter: ' ' }
      )
      );
    }
    return letters;
  }
}

class Board extends React.Component {
  render() {
    var attempt_items = this.props.game.attempts.map((attempt, index) => {
      var word = attempt[0];
      var matches = attempt[1];

      return    React.createElement(
        WordGuess,
        { key: index, word: word, matches: matches }
      )
    });


    if(attempt_items.length != 6) {
      var current_word_matches = this.props.current_word.split('').map((letter, index) => {
        if (this.props.warning_letters && this.props.warning_letters.includes(letter)) {
          return 4;
        }else {
          return -1;
        }
      });

      attempt_items.push(React.createElement(
        WordGuess,
        { key: 99, word: this.props.current_word, matches: current_word_matches }
      ));
    }

    for(var i = 0; i < (5 - this.props.game.attempts.length); i++) {
      attempt_items.push(React.createElement(
        WordGuess,
        { key: i + 10, word: '', matches: [] }
      )
      );
    }

    var className = 'grid grid-cols-5 gap-1 m-1'

    if(this.props.game.status == 'won') {
      className += ' animation-win'
    }

    return React.createElement(
      'div',
      { className: className },
      attempt_items
    );
  }
}

