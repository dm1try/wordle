require 'spec_helper'
require_relative '../app'

describe 'App', type: :rack do
  def app
    App.build
  end

  it 'opens a new-game page' do
    get '/'
    expect(last_response).to be_ok
    expect(last_response.body).to include('New Game')
  end

  it 'opens a game page' do
    get '/game'
    expect(last_response).to be_ok
    expect(last_response.body).to include('Game')
  end
end
