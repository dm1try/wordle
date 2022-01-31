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
    expect(page).to have_content 'Start a new co-op game'

    find("button", :text => "Start a new co-op game").click
    expect(page).to have_content 'WORDLE'

    find("body").send_keys("plain\n")

    expect(page).to have_content "P\nL\nA\nI\nN\n"
    expect(page).to have_content "You win!"
  end

  context 'multiplayer mode' do

    it 'allows to do the competion between players' do
      Capybara.using_session('player1') do
        visit '/'
        expect(page).to have_content 'Start a new multiplayer game'

        find("button", :text => "Start a new multiplayer game").click
        expect(page).to have_content 'WORDLE'
        @game_url = page.current_url
      end

      Capybara.using_session('player2') do
        visit @game_url
        expect(page).to have_content 'WORDLE'
      end

      Capybara.using_session('player1') do
        find("#start_game").click
        find("body").send_keys("ololo\n")

        expect(page).to have_content "not found"
      end

      Capybara.using_session('player2') do
        find("body").send_keys("plain\n")

        expect(page).to have_content "Game ended in "
        expect(page).to have_content "Winner: Wordler 2"
      end

      Capybara.using_session('player1') do
        expect(page).to have_content "Game ended in "
        expect(page).to have_content "Winner: Wordler 2"
      end
    end
  end
end


describe 'App', type: :rack do
  def app
    App.build
  end
end
