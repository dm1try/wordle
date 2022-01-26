class Board extends React.Component {
  render() {
    var attempt_items = this.props.attempts.map((attempt, index) => {
      return React.createElement(
        'li',
        { key: index},
        attempt[0]
      )
    });

    console.log(attempt_items);
    return React.createElement(
      'ul',
      { },
      attempt_items
    );
  }
}

