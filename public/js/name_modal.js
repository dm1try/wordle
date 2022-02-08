class NameModal extends React.Component {
  constructor(props) {
    super(props);
    this.state = {show: false};
  }

  onIconClick(e) {
    this.setState({show: !this.state.show});
  }

  onKeyDown(e) {
    e.stopPropagation();
    if (e.keyCode === 13) {
      e.preventDefault();
    }
  }

  onKeyUp(e) {
    e.stopPropagation();
    if (e.keyCode === 13) {
      e.preventDefault();
      var value = e.target.value;
      if(this.props.onSubmit) {
        this.props.onSubmit(value);
      }else{
        console.log("No onSubmit function defined");
      }
      this.setState({show: false});
    }
  }

  render() {
    var form = null;
    if (this.state.show){
      form = React.createElement(
        "form",
        {className: "rounded fixed my-8 -mx-40 border-2 border-gray-200 p-2",
          style: {backgroundColor: '#f5f5f5'}},
        React.createElement('input', {type: "text",
          name: "player_name",
          defaultValue: this.props.value,
          onKeyUp: this.onKeyUp.bind(this),
          onKeyDown: this.onKeyDown.bind(this),
          autoFocus: true,
          className: "",
          placeholder: "Enter your name",
        })
      )
    }

    return React.createElement('div', {
      className: 'flex'
    },
      React.createElement("svg", {
        xmlns: "http://www.w3.org/2000/svg",
        className: "h-6 w-6 cursor-pointer",
        fill: "none",
        viewBox: "0 0 24 24",
        stroke: "currentColor",
        onClick: this.onIconClick.bind(this)
      }, React.createElement("path", {
        strokeLinecap: "round",
        strokeLinejoin: "round",
        strokeWidth: 2,
        d: "M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
      })),
      form
    )
  }
}

