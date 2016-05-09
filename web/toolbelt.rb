ENV["HEROKU_NAV_URL"] = "https://nav.heroku.com/v2"

require "compass"
require "rdiscount"
require "heroku/nav"
require "sinatra"
require "json"
require "uri"
require "rollbar"

class Toolbelt < Sinatra::Base

  use Heroku::Nav::Header

  configure do
    Compass.configuration do |config|
      config.project_path = File.dirname(__FILE__)
      config.sass_dir = 'views'
    end

    set :haml, { :format => :html5 }
    set :sass, Compass.sass_engine_options
    set :static, true
    set :root, File.expand_path("../", __FILE__)
    set :views, File.expand_path("../views", __FILE__)
    set :logging, false

    Rollbar.configure do |config|
      config.access_token = ENV['ROLLBAR_ACCESS_TOKEN']
      config.environment = Sinatra::Base.environment
      config.framework = "Sinatra: #{Sinatra::VERSION}"
      config.root = Dir.pwd

      config.scrub_headers |= [
        'Cookie',
        'Set-Cookie',
        'X_CSRF_TOKEN'
      ]

      config.scrub_fields |= [
        'access_token',
        'api_key',
        'authenticity_token',
        'bounder.refresh_token',
        'bouncer.token',
        'confirm_password',
        '_csrf_token',
        'heroku_oauth_token',
        'heroku_session_nonce',
        'heroku_user_session',
        'oauth_token',
        'password',
        'password_confirmation',
        'secret',
        'secret_token',
        'session_id',
        'user_session_secret',
        'toolbelt-sso-session',
      ]
    end
  end

  class RequestDataExtractor
    include Rollbar::RequestDataExtractor
    def from_rack(env)
      extract_request_data_from_rack(env).merge({
        :route => env["PATH_INFO"]
      })
    end
  end

  error do
    request_data = RequestDataExtractor.new.from_rack(env)
    Rollbar.report_exception(env['sinatra.error'], request_data)
    status 500
    "Internal Server Error"
  end

  configure :production do
    require "rack-ssl-enforcer"
    use Rack::SslEnforcer, :except => %r{^/ubuntu/}
  end

  helpers do
    def markdown_plus(partial, opts={})
      content = markdown(partial, opts)

      content.gsub(/<code>(.*?)<\/code>/m) do |match|
        match.gsub(/\$(.*)\n/, "<span class=\"highlight\">$\\1</span>\n")
      end
    end

    def newest_mtime
      @newest_mtime ||= begin
        Dir[File.join(settings.views, "**")].map do |file|
          File.mtime(file)
        end.sort.last
      end
    end

    def useragent_platform
      case request.user_agent
        when /Mac OS X/ then :osx
        when /Linux/    then :debian
        when /Windows/  then :windows
        else                 :osx
      end
    end
  end

  def log_page_visit(req)
    log_event(req, 'PageVisit')
  end

  def log_download(req)
    log_event(req, 'Download')
  end

  def log_event(req, event_type)
    event = { 'page_title' => nil, 'referrer_query_string' => nil, 'user_heroku_uid' => nil, 'user_email' => nil, 'who' => nil }
    event['page_url'] = req.base_url + req.path # Don't want url b/c that includes query_string
    event['page_query_string'] = req.query_string
    event['referrer_url'] = req.referer
    event['source_ip'] = req.ip

    event['at'] = Time.now
    event['event_type'] = event_type
    event['component'] = 'toolbelt'

    STDOUT.puts event.to_json
  end

  get "/" do
    log_page_visit(request)
    last_modified newest_mtime
    haml :index, :locals => { :platform => useragent_platform }
  end

  %w( osx windows debian standalone ).each do |platform|
    get "/#{platform}" do
      log_page_visit(request)
      if request.xhr?
        markdown_plus platform.to_sym
      else
        last_modified newest_mtime
        haml :index, :locals => { :platform => platform.to_sym }
      end
    end
  end

  get "/update/hash" do
    ENV["UPDATE_HASH"].to_s
  end

  get "/:name.css" do
    last_modified newest_mtime
    sass params[:name].to_sym rescue not_found
  end

  # apt repository
  get "/ubuntu/*" do
    dir = params[:splat].first.gsub(/^\.\//, "")
    if request.secure?
      redirect "https://heroku-toolbelt.s3.amazonaws.com/apt/#{dir}"
    else
      redirect "http://heroku-toolbelt.s3.amazonaws.com/apt/#{dir}"
    end
  end

  get "/download/windows" do
    log_download(request)
    redirect "https://s3.amazonaws.com/assets.heroku.com/heroku-toolbelt/heroku-toolbelt.exe"
  end

  get "/download/osx" do
    log_download(request)
    redirect "https://s3.amazonaws.com/assets.heroku.com/heroku-toolbelt/heroku-toolbelt.pkg"
  end

  get "/download/zip" do
    log_download(request)
    redirect "http://s3.amazonaws.com/assets.heroku.com/heroku-client/heroku-client.zip"
  end

  get "/download/beta-zip" do
    log_download(request)
    redirect "http://s3.amazonaws.com/assets.heroku.com/heroku-client/heroku-client-beta.zip"
  end

  # linux install instructions
  get "/install-ubuntu.sh" do
    if request.user_agent =~ /curl|wget/i # viewing in the browser shouldn't count as a download
      log_download(request)
    end
    content_type "text/plain"
    erb :"install-ubuntu"
  end

  get "/install.sh" do
    if request.user_agent =~ /curl|wget/i # viewing in the browser shouldn't count as a download
      log_download(request)
    end
    content_type "text/plain"
    erb :"install.sh"
  end

  get "/install-other.sh" do
    if request.user_agent =~ /curl|wget/i # viewing in the browser shouldn't count as a download
      log_download(request)
    end
    content_type "text/plain"
    erb :"install.sh"
  end

  # legacy redirects
  get("/osx/download")     { redirect "/osx"        }
  get("/windows/download") { redirect "/windows"    }
  get("/linux/readme")     { redirect "/linux"      }
  get("/linux")            { redirect "/debian"     }
  get("/other")            { redirect "/standalone" }
end
