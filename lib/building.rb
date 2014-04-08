require 'yaml'
require 'fileutils'
require 'bundler/setup' 
require 'highline/import'

class Building
  def self.convert(app_name, tag, options={})
    Building.new(app_name, tag, options)
  end

  def initialize(app_name, tag, options={})
    @app_name = app_name
    @tag = tag || "latest"
    @buildpack_url = options[:buildpack_url]
    @includes = options[:includes]
    @file = options[:file]
    @from = options[:from]
    @fig = options[:fig]
    @port = options[:port]

    create_dockerfile
    build_container

    build_fig if @fig

    if @port
      run_container(@port)
    else
      explain_container(8080)
    end

    exit 0
  end

  def create_dockerfile
    dockerfile = []
    dockerfile << "FROM #{@from || "ctlc/buildstep:ubuntu13.10"}\n"

    if @buildpack_url
      dockerfile << <<-eof
RUN git clone --depth 1 #{@buildpack_url} /build/buildpacks/#{@buildpack_url.split("/").last.sub(".git","")}
RUN echo #{@buildpack_url} >> /build/buildpacks.txt
eof
    end

    if @includes
      dockerfile << "RUN #{@includes}\n"
    end

    if @file
      dockerfile << IO.read(@file)
    end

    dockerfile << <<-eof
ADD . /app
RUN /build/builder
CMD /start web
eof
    
    skip = false

    if File.exists?("Dockerfile")
      if IO.read("Dockerfile") == dockerfile.join("\n")
        skip = true
        say %{   <%= color('identical', [BLUE, BOLD]) %>  Dockerfile}
      else
        say %{    <%= color('conflict', [RED, BOLD]) %>  Dockerfile}
        choice = ask("Overwrite Dockerfile? [Yn] ")
        if choice.downcase == "n"
          say("Aborting...")
          exit 1
        else
          say %{       <%= color('force', [YELLOW, BOLD]) %>  Dockerfile}
        end
      end
    else
      say %{      <%= color('create', [GREEN, BOLD]) %>  Dockerfile}
    end

    if !skip
      File.open("Dockerfile" , "w") do |file|
        file << dockerfile.join("\n")
      end
    end
  end

  def build_fig
    figfile = <<-eof
web:
  image: #{@app_name}:#{@tag}
  command: /start web
  environment:
    PORT: #{@port || 8080}
  ports:
   - #{@port || 8080}
eof

    skip = false
    
    if File.exists?(@fig)
      if IO.read(@fig) == figfile
        skip = true
        say %{   <%= color('identical', [BLUE, BOLD]) %>  #{@fig}}
      else
        say %{    <%= color('conflict', [RED, BOLD]) %>  #{@fig}}
        choice = ask("Overwrite #{File.expand_path(@fig)}? [Yn] ")
        if choice.downcase == "n"
          say("Aborting...")
          exit 1
        else
          say %{       <%= color('force', [YELLOW, BOLD]) %>  #{@fig}}
        end
      end
    else
      say %{      <%= color('create', [GREEN, BOLD]) %>  #{@fig}}
    end

    if !skip
      File.open(@fig , "w") do |file|
        file << figfile
      end
    end
  end

  def build_container
    build_cmd = "docker build -t #{@app_name}:#{@tag} ."
    say %{    <%= color('building', [BLUE, BOLD]) %>  #{build_cmd}}
    pid = fork { exec build_cmd }
    Process.waitpid(pid)
  end

  def explain_container(port)
    run = "docker run -d -p #{port} -e \"PORT=#{port}\" #{@app_name}:#{@tag}"
    rebuild = "docker build -t #{@app_name} ."

    say "        <%= color('hint', [YELLOW, BOLD]) %>       To run your app, try:  <%= color('#{run}', [BOLD]) %>"
    say "        <%= color('hint', [YELLOW, BOLD]) %>  To re-build your app, try:  <%= color('#{rebuild}', [BOLD]) %>"
  end

  def run_container(port)
    run = "docker run -d -p #{port} -e \"PORT=#{port}\" #{@app_name}:#{@tag}"
    say "     <%= color('running', [BLUE, BOLD]) %>  #{run}"
    exec run
  end
end
