require 'yaml'
require 'fileutils'

class App2Container
  def self.convert(app_name, tag, options={})
    App2Container.new(app_name, tag, options)
  end

  def initialize(app_name, tag, options={})
    @app_name = app_name
    @tag = tag || "latest"
    create_dockerfile(options[:buildpack])
    build_container(tag)

    if options[:port]
      run_container(options[:port])
    else
      explain_container(8080)
    end
    exit 0
  end

  def create_dockerfile(buildpack_url)
    if buildpack_url
      File.open("Dockerfile" , "w") do |file|
        file << <<-eof
  FROM progrium/buildstep
  RUN git clone #{buildpack_url} /build/buildpacks
  RUN echo #{buildpack_url} >> /build/buildpacks.txt
  RUN /stack/builder
  ADD . /app
  RUN /build/builder
  CMD /start web
  eof
      end
    elsif !File.exists?("Dockerfile")
    	File.open("Dockerfile" , "w") do |file|
        file << <<-eof
  FROM progrium/buildstep
  ADD . /app
  RUN /build/builder
  CMD /start web
  eof
      end
    end
  end

  def build_container
    pid = fork { exec "docker build -t #{@app_name}:#{@tag} ." }
    Process.waitpid(pid)
  end

  def explain_container(port)
    run = "docker run -d -p #{port} -e \"PORT=#{port}\" #{@app_name}"
    puts "\nTo run your app, try something like this:\n\n\t#{run}\n\n"
  end

  def run_container(port)
    run = "\ndocker run -d -p #{port} -e \"PORT=#{port}\" #{@app_name}"
    puts "#{run}"
    exec run
  end
end
