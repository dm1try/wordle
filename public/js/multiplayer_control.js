class MultiplayerControl extends React.Component {
  is_hidden() {
    return this.props.started_at != null
  }

  render() {
    return React.createElement(
      'button',
      { className: 'rounded bg-green-500 text-gray-100 border mx-2 px-2', onClick: this.props.onClick, hidden: this.is_hidden() },
      'Go'
    )
  }
}
