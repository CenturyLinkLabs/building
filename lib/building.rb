require 'yaml'
require 'fileutils'

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

    if @port
      run_container(@port)
    else
      explain_container(8080)
    end

    if @fig
      build_fig
    end

    exit 0
  end

  def create_dockerfile
    File.open("Dockerfile" , "w") do |file|
      file << "FROM #{@from || "ctlc/buildstep:ubuntu13.10"}\n"
    end

    if @buildpack_url
      File.open("Dockerfile" , "a") do |file|
        file << <<-eof
RUN git clone --depth 1 #{@buildpack_url} /build/buildpacks/#{@buildpack_url.split("/").last.sub(".git","")}
RUN echo #{@buildpack_url} >> /build/buildpacks.txt
eof
      end
    end

    if @includes
      File.open("Dockerfile" , "a") do |file|
        file << "RUN #{@includes}\n"
      end
    end

    if @file
      File.open("Dockerfile" , "a") do |file|
        file << IO.read(@file)
      end
    end

    File.open("Dockerfile" , "a") do |file|
      file << <<-eof
ADD . /app
RUN /build/builder
CMD /start web
eof
    end
  end

  def build_fig
    File.open(@fig , "w") do |file|
      file << <<-eof
web:
  image: #{@app_name}:#{@tag}
  command: /start web
  environment:
    PORT: #{@port || 8080}
  ports:
   - #{@port || 8080}
eof
    end
  end

  def build_container
    pid = fork { exec "docker build -t #{@app_name}:#{@tag} ." }
    Process.waitpid(pid)
  end

  def explain_container(port)
    run = "docker run -d -p #{port} -e \"PORT=#{port}\" #{@app_name}:#{@tag}"
    puts "\nTo run your app, try something like this:\n\n\t#{run}\n\n"
  end

  def run_container(port)
    run = "\ndocker run -d -p #{port} -e \"PORT=#{port}\" #{@app_name}:#{@tag}"
    puts "#{run}"
    exec run
  end
end
