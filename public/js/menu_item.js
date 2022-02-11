class MenuItem extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      title: props.title,
    };
  }
  onClick() {
    this.props.onClick();
    if(this.props.afterClickTitle) {
      this.setState({ title: this.props.afterClickTitle });
      setTimeout(() => {
        this.setState({ title: this.props.title });
      }, 1500);
    }
  }
  render() {
    console.log(this.state.title);
    return React.createElement('div', {
      "data-tooltip-target": "tooltip-bottom-" + this.props.id,
      "data-tooltip-placement": "bottom",
    },
      React.createElement("svg", {
        xmlns: "http://www.w3.org/2000/svg",
        className: "mx-1 h-6 w-6 cursor-pointer",
        fill: "none",
        viewBox: "0 0 24 24",
        stroke: "currentColor",
        onClick: this.onClick.bind(this),
      }, React.createElement("path", {
        strokeLinecap: "round",
        strokeLinejoin: "round",
        strokeWidth: 2,
        d: this.props.path_d
      })),
      React.createElement("div", {
        id: "tooltip-bottom-" + this.props.id,
        role: "tooltip",
        className: "inline-block absolute invisible z-10 py-2 px-3 text-sm font-medium text-white bg-gray-900 rounded-lg shadow-sm opacity-0 tooltip dark:bg-gray-700"
      }, this.state.title, React.createElement("div", {
        className: "tooltip-arrow",
        "data-popper-arrow": true
      })
      )
    )
  }
}
