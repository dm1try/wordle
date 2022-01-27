class WordLetter extends React.Component {
  render(){
    var className =  'text-center text-4xl leading-normal box-border h-16  border-2 text-bold uppercase';

    if (this.props.match == 1) {
      className += ' bg-yellow-500 text-white';
    } else if(this.props.match == 2) {
      className += ' bg-green-500 text-white';
    } else if(this.props.match == 0) {
      className += ' bg-gray-500 text-white';
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
    var letters = this.props.word.split('').map((letter, index) => {
      return    React.createElement(
        WordLetter,
        { key: index, letter: letter, match: this.props.matches[index] }
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
    var attempt_items = this.props.attempts.map((attempt, index) => {
      var word = attempt[0];
      var matches = attempt[1];

      return    React.createElement(
        WordGuess,
        { key: index, word: word, matches: matches }
      )
    });


    if(attempt_items.length != 6) {
      attempt_items.push(React.createElement(
        WordGuess,
        { key: 99, word: this.props.current_word, matches: Array(this.props.current_word.length) }
      ));
    }

    for(var i = 0; i < (5 - this.props.attempts.length); i++) {
      attempt_items.push(React.createElement(
        WordGuess,
        { key: i + 10, word: '', matches: [] }
      )
      );
    }

    return React.createElement(
      'div',
      { className: 'grid grid-cols-5 gap-2' },
      attempt_items
    );
  }
}
