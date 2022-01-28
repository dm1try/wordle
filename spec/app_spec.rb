require 'spec_helper'
require_relative '../app'
require 'webdrivers'

Capybara.default_driver = :selenium_chrome
Capybara.run_server = false
Capybara.app_host = 'http://127.0.0.1:1234'

describe "Wordle", type: :feature do
  before do
    @server_pid = Process.spawn("APP_ENV=test REDIS_URL=redis://localhost:6379/2 bundle exec tipi server.rb")
  end

  after do
    Process.kill("TERM", @server_pid)
  end

  it "allows to play a new game and win :)" do
    visit '/'
    expect(page).to have_content 'Start a new game'

    find("button", :text => "Start a new game").click
    expect(page).to have_content 'WORDLE'
    
    find("body").send_keys("plain\n")

    expect(page).to have_content "P\nL\nA\nI\nN\n"
    expect(page).to have_content "You win!"
  end
end

describe 'App', type: :rack do
  def app
    App.build
  end
end
