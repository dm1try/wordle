class Button extends React.Component {
  onClick() {
    this.props.onKeyPress(this.props.code);
  }

  render() {
    return (
      React.createElement("button", {
        className: "bg-gray-100 border text-2xl rounded px-1 py-1 text-" + this.props.color + "-600",
        onClick: this.onClick.bind(this)
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
              onKeyPress: this.props.onKeyPress
            })
          } else {
            return React.createElement(Button, {
              key: index,
              code: button.code,
              display: button.display || button.code.toUpperCase(),
              color: button.color || "black",
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
      { className: 'keyboard grid grid-rows-3 gap-1' },
      this.props.rows.map((row, index) => {
        return React.createElement(ButtonsRow, {
          key: index,
          buttons: row,
          onKeyPress: this.props.onKeyPress
        })
      })
    )
  }
}
