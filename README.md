building
==========
Build a Docker container for any app using Heroku Buildpacks

Install
-------

	$ sudo gem install building
	$ building
	Usage: building [options] CONTAINER_NAME [TAG]
    -o, --output FIGCONF             Output a fig configuration file
    -f, --from FROM                  Change the default FROM (progrium/buildstep)
    -d, --dockerfile DOCKERFILE      External Dockerfile to append to the building generated Dockerfile
    -i, --include CMD                Extra commands during the image build
    -b, --buildpack URL              Add an external Buildpack URL
    -p, --p PORT                     Run the container after it is built on a certain port
    -h, --help                       Display this screen

Usage
-----

To convert any app into a Docker container using Heroku Buildpacks, just use this simple gem.

	$ building myuser/container-name
	$ docker run -d -p 8080 -e "PORT=8080" myuser/container-name

You can version your apps by adding a verison number.

	$ building myuser/container-name 1.2
	$ docker run -d -p 8080 -e "PORT=8080" myuser/container-name:1.2

Also, you can have building run the app for you automatically by adding a -p flag with a port number.

	$ building -p 8080 myuser/container-name 1.2

Fig Integration
---------------

If you never want to interact with the docker command line, building can pair up with fig with the -o flag.
	
	$ brew install python # if you are on a Mac
	$ sudo pip install -U fig
	$ building -o fig.yml myuser/container-name
	$ fig up -d
	Creating myapp_web_1...
	$ fig scale web=3
	Starting myapp_web_2...
	Starting myapp_web_3...
	$ fig ps
    Name        Command     State        Ports      
    --------------------------------------------------
    myapp_web_3   /start web   Up      49192->8080/tcp 
    myapp_web_2   /start web   Up      49191->8080/tcp 
    myapp_web_1   /start web   Up      49190->8080/tcp 

This gives you a full Heroku like scaling environment in just a few easy commands.

External Buildpacks
-------------------

To add an external buildpack, you can specify it with a -b flag. For example, here is how to get HHVM working in a Docker container:

	$ building -b https://github.com/hhvm/heroku-buildpack-hhvm.git -f ctlc/buildstep:ubuntu12.04 wordpress

In this case, the latest buildpack is compiled against Ubuntu 13.10, whereas the default Linux distro used for HHVM is Ubuntu 12.10.

Adding Your Own Packages to the Standard Container
--------------------------------------------------

Sometimes you need a few more packages built-in to your container. Here is how to do that:

	$ building -i "apt-get update && apt-get install -qy libapache2-mod-php5 php5-mysql php5-memcache php5-curl" wordpress

Or you can save your modifications to a file for a cleaner building command.

	$ echo "apt-get update && apt-get install -qy libapache2-mod-php5 php5-mysql php5-memcache php5-curl" > Dockerfile.include
	$ building -f Dockerfile.include wordpress


Creating Your Own Base Containers
---------------------------------

Other times, you will need a more customized OS tuned to your needs. For example, the HHVM example above uses a custom VM. You can use https://github.com/progrium/buildstep as a starting point to build any container version you need for your applications. Here is how I built ctlc/buildstep:ubuntu12.04:

	$ git clone https://github.com/progrium/buildstep.git
	$ cd buildstep
	$ echo "FROM ubuntu:lucid
	RUN apt-get update && apt-get install python-software-properties -y
	RUN apt-add-repository ppa:brightbox/ruby-ng
	RUN apt-get update && apt-get install git-core curl rubygems libmysqlclient-dev libxml2 libxslt1.1 libfreetype6 libjpeg-dev liblcms-utils libxt6 libltdl-dev -y
	RUN mkdir /build
	ADD ./stack/ /build
	RUN LC_ALL=C DEBIAN_FRONTEND=noninteractive /build/prepare
	RUN apt-get clean" > Dockerfile

	$ docker build -t ctlc/buildstep:ubuntu12.04 .
	$ docker push ctlc/buildstep
