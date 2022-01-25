require 'spec_helper'
require_relative '../app'

describe 'App', type: :rack do
  def app
    App.new
  end

  it 'should have a root route' do
    get '/'
    expect(last_response).to be_ok
  end
end
