class Button extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      pressed: false
    };
  }

  onMouseDown() {
    this.setState({
      pressed: true
    });
  }

  onMouseUp() {
    this.setState({
      pressed: false
    });
    this.props.onKeyPress(this.props.code);
  }

  render() {
    var bgColorClass = this.state.pressed ? 'bg-gray-300' : 'bg-gray-100';

    var textColorClass = 'text-' + this.props.color + '-600';
    if (this.props.marked) {
      textColorClass = 'text-gray-200';
    }

    return (
      React.createElement("button", {
        className: bgColorClass + " border text-2xl rounded px-1 py-1 " + textColorClass,
        onMouseDown: this.onMouseDown.bind(this),
        onMouseUp: this.onMouseUp.bind(this),
      },
      this.props.display || this.props.code.toUpperCase())
    );
  }
}

class ButtonsRow extends React.Component {
  render() {
    return (
      React.createElement("div", {
        className: "row text-center grid grid-cols-" + this.props.buttons.length + " gap-1"
      },
        this.props.buttons.map((button, index) => {
          if(typeof(button) === 'string') {
            return React.createElement(Button, {
              key: index,
              code: button,
              display: button.toUpperCase(),
              color: "black",
              marked: this.props.marked_buttons.includes(button),
              onKeyPress: this.props.onKeyPress
            })
          } else {
            return React.createElement(Button, {
              key: index,
              code: button.code,
              display: button.display || button.code.toUpperCase(),
              color: button.color || "black",
              marked: this.props.marked_buttons.includes(button.code),
              onKeyPress: this.props.onKeyPress
            })
          }
        })
      )
    )
  }
}

class Keyboard extends React.Component {
  render(){

    return  React.createElement(
      'div',
      { className: 'keyboard grid grid-rows-3 gap-1 my-1' },
      this.props.rows.map((row, index) => {
        return React.createElement(ButtonsRow, {
          key: index,
          buttons: row,
          marked_buttons: this.props.marked_buttons || [],
          onKeyPress: this.props.onKeyPress
        })
      })
    )
  }
}
