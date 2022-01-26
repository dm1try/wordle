require 'spec_helper'
require_relative '../app'
require 'webdrivers'

Capybara.default_driver = :selenium_chrome
Capybara.run_server = false
Capybara.app_host = 'http://127.0.0.1:1234'

describe "Wordle", type: :feature do
  before do
    @server_pid = Process.spawn("bundle exec tipi server.rb")
  end

  after do
    Process.kill("TERM", @server_pid)
  end

  it "allows to play a new game" do
    visit '/'
    expect(page).to have_content 'New Game'

    click_button 'start'
    expect(page).to have_content 'Wordle'
    expect(page).to have_content 'connected'
    
    fill_in 'word_input', with: "plain\n"

    expect(page).to have_content 'won'
  end
end

describe 'App', type: :rack do
  def app
    App.build
  end
end
