require "erb"

# this function is only called once to package the heroku cli distribution zip
# through its build:zip task, which also vendors in the correct gems and other
# such hotchpotchery.
# It's is especially fun-tastic as its return value is the path to the
# resulting zip file, which we immediately proceed to pass to the extract_zip
# function, which is also just called once, and does exactly what it says on
# the tin.
def build_zip(name)
  rm_rf "#{component_dir(name)}/.bundle"
  rm_rf Dir["#{basedir}/components/#{name}/pkg/*.zip"]
  component_bundle name, 'install --without development --quiet'
  component_bundle name, "exec rake zip:clean zip:build #{windows? ? '1>nul' : '1>/dev/null'}"
  Dir["#{basedir}/components/#{name}/pkg/*.zip"].first
end

# see comment on build_zip
def extract_zip(filename, destination)
  tempdir do |dir|
    sh %{ unzip -q "#{filename}" }
    sh %{ mv * "#{destination}" }
  end
end

# file task for the final windows installer file.
# if you ask me, it's fairly pointless to be using a file task for the final
# file if the intermediates get placed in all sorts of temp dirs that then get
# destroyed, so we we don't get to benefit from the time savings of not
# generating the same thing over and over again.
file pkg("heroku-toolbelt-#{version}.exe") do |t|
  tempdir do |dir|
    # gather the heroku cli files
    mkdir_p "#{dir}/heroku"
    extract_zip build_zip("heroku"), "#{dir}/heroku/"

    # gather the ruby and git installers, downlading from s3
    mkchdir("installers") do
      ["rubyinstaller.exe", "git.exe"].each do |i|
        cache = File.expand_path(File.join(File.dirname(__FILE__), "..", ".cache", i))
        FileUtils.mkdir_p File.dirname(cache)
        unless File.exists? cache
          system %Q{curl http://heroku-toolbelt.s3.amazonaws.com/#{i} -o "#{cache}"}
        end
        cp cache, i
      end
    end

    # add windows helper executables to the heroku cli
    cp resource("exe/heroku.bat"), "heroku/bin/heroku.bat"
    cp resource("exe/heroku"),     "heroku/bin/heroku"

    # render the iss file used by inno setup to compile the installer
    # this sets the version, and the output path and filename so it ends up where we want it
    File.open("heroku.iss", "w") do |iss|
      iss.write(ERB.new(File.read(resource("exe/heroku.iss"))).result(binding))
    end

    # finally, run the inno compiler to build and sign the installer
    inno_dir = ENV["INNO_DIR"] || 'C:\Program Files (x86)\Inno Setup 5'
    signtool = ENV["SIGNTOOL"] || 'C:\Program Files\Microsoft SDKs\Windows\v7.1\Bin\signtool.exe'
    password = ENV["CERT_PASSWORD"]
    # TODO: can't have a space in the certificate path; keeping it in C: root sucks
    sign_with = "/sStandard=#{signtool} sign /d Heroku-Toolbelt /f C:\\Certificates.p12 /v /p #{password} $f"
    sleep 1 # try to get around signed file being held by previous process.
    system %Q{"#{inno_dir}\\iscc" /qp "#{sign_with}" /cc "heroku.iss"}
  end
end

desc "Clean exe"
task "exe:clean" do
  clean pkg("heroku-toolbelt-#{version}.exe")
  clean File.join(File.dirname(__FILE__), "..", ".cache")
end

desc "Build exe"
task "exe:build" => pkg("heroku-toolbelt-#{version}.exe")

desc "Release exe"
task "exe:release" => "exe:build" do |t|
  store pkg("heroku-toolbelt-#{version}.exe"), "heroku-toolbelt/heroku-toolbelt-#{version}.exe"
  store pkg("heroku-toolbelt-#{version}.exe"), "heroku-toolbelt/heroku-toolbelt-beta.exe" if beta?
  store pkg("heroku-toolbelt-#{version}.exe"), "heroku-toolbelt/heroku-toolbelt.exe" unless beta?
end

# Mono's signcode tool can't take the private key passphrase non-interactively (read file, pass as parameter),
# so to run the build non-interactively we have to use a passphrase-less key. To keep the private key secure,
# the key that comes from the repository is encrypted. You can either run exe:build and type in the passphrase
# manually (twice!), or decode it for good with this task.
#
# Ensure your build environment is secure before leaving an unencrypted private key lying around.
#
# Additionally, Mac OS X's default openssl, as of Mavericks, is 0.9.8y, which doesn't support the pvk format.
# The 1.0.x tree does, and you can install it via homebrew (brew install openssl), but it's keg-only, so it'll
# not be in your PATH. You could `brew link` it, but it's safer to leave it alone. Hence you can pass the full
# path to the openssl binary to be used via the OPENSSL_PATH environment variable:
#
#    OPENSSL_PATH=`brew --prefix openssl`/bin/openssl rake exe:pvk-nocrypt
desc "Remove passphrase from heroku-codesign-cert.pvk so signcode doesn't ask for it, making the exe:build task non-interactive"
task "exe:pvk-nocrypt" do
  openssl = (ENV["OPENSSL_PATH"] || "openssl").shellescape
  keyfile = resource('exe/heroku-codesign-cert.pvk').shellescape
  version = `#{openssl} version`.chomp
  raise "OpenSSL version should be 1.0.x; instead got: #{version}" if version !~ /^OpenSSL 1\./
  system "#{openssl} rsa -inform PVK -outform PVK -pvk-none -in #{keyfile} -out #{keyfile}"
end
