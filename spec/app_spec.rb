require 'spec_helper'
require 'webdrivers'

Capybara.default_driver = :selenium_chrome
Capybara.run_server = false
Capybara.app_host = 'http://127.0.0.1:1234'

describe "Wordle", type: :feature do
  before do
    @server_pid = Process.spawn("APP_ENV=test REDIS_URL=redis://localhost:6379/2 bundle exec tipi app.rb")
  end

  after do
    Process.kill("TERM", @server_pid)
  end

  context 'cooperative mode' do
    it "allows to play a new game and win :)" do
      visit '/'
      expect(page).to have_content 'Start'

      select "Cooperative Mode 🤝", :from => "mode"
      find("button", :text => "Start").click
      expect(page).to have_content 'WORDLE'

      find("body").send_keys("plain\n")

      expect(page).to have_content "P\nL\nA\nI\nN\n"
      expect(page).to have_content "You win!"
    end
  end

  context 'multiplayer mode' do

    it 'allows to do the competion between players' do
      Capybara.using_session('player1') do
        visit '/'
        expect(page).to have_content 'Start'

        select "Competition Mode 🏁", :from => "mode"
        find("button", :text => "Start").click
        expect(page).to have_content 'WORDLE'
        @game_url = page.current_url
      end

      Capybara.using_session('player2') do
        visit @game_url
        expect(page).to have_content 'WORDLE'
      end

      Capybara.using_session('player1') do
        find("button", :text => "Go").click
        find("body").send_keys("ololo\n")

        expect(page).to have_content "not found"
      end

      Capybara.using_session('player2') do
        find("body").send_keys("plain\n")

        expect(page).to have_content "Wordler 2 won in"
      end

      Capybara.using_session('player1') do
        expect(page).to have_content "Wordler 2 won in"
      end
    end
  end
end


describe 'App', type: :rack do
  def app
    App.build
  end
end
