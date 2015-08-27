require_relative "test_helper"

describe Toolbelt do
  include Rack::Test::Methods

  def app
    @app
  end

  before do
    @app = Toolbelt.new
  end

  context "the toolbelt website" do
    it "logs page visit events without recording hits" do
      toolbelt.expects(:record_hit).never
      toolbelt.expects(:log_event).with(anything, 'PageVisit').times(page_visit_paths.size)

      page_visit_paths.each do |path|
        get path

        assert_equal 200, last_response.status
      end
    end

    it "logs download events and records hits for download requests coming from browsers" do
      toolbelt.expects(:record_hit).times(browser_download_paths.size)
      toolbelt.expects(:log_event).with(anything, 'Download').times(browser_download_paths.size)

      browser_download_paths.each do |path|
        get path
      end
    end

    it "logs download events and records hits for curl/wget requests coming from curl/wget" do
      toolbelt.expects(:record_hit).times(shell_download_paths.size * 2)
      toolbelt.expects(:log_event).with(anything, 'Download').times(shell_download_paths.size * 2)

      shell_download_paths.each do |path|
        get path, {}, { 'HTTP_USER_AGENT' => 'curl' }
        get path, {}, { 'HTTP_USER_AGENT' => 'wget' }
      end
    end
  end

  def non_ubuntu_paths
    page_visit_paths + browser_download_paths
  end

  def ubuntu_paths
    %w( /ubuntu/./Release.gpg /ubuntu/./Packages /ubuntu/./en_US /ubuntu/./en )
  end

  def page_visit_paths
    %w( /osx /windows /debian /standalone )
  end

  def browser_download_paths
    %w( /download/windows /download/osx /download/zip /download/beta-zip )
  end

  def shell_download_paths
    %w( /install-ubuntu.sh /install.sh /install-other.sh )
  end

  def toolbelt
    Toolbelt.any_instance
  end
end
