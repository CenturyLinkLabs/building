app2container
==========
Build a Docker container for any app using Heroku Buildpacks

Install
-------

	$ sudo gem install app2container
	$ app2container
	Usage: app2container [options] CONTAINER_NAME [TAG]
        --from FROM                  Change the default FROM (progrium/buildstep)
    -f, --file Dockerfile            External Dockerfile to append to the app2container generated Dockerfile
    -i, --include CMD                Extra commands during the image build
    -b, --buildpack URL              Add an external Buildpack URL
    -p, --p PORT                     Run the container after it is built on a certain port
    -h, --help                       Display this screen

Usage
-----

To convert any app into a Docker container using Heroku Buildpacks, just use this simple gem.

	$ app2container myuser/container-name
	$ docker run -d -p 8080 -e "PORT=8080" myuser/container-name

You can version your apps by adding a verison number.

	$ app2container myuser/container-name 1.2
	$ docker run -d -p 8080 -e "PORT=8080" myuser/container-name:1.2

Also, you can have app2container run the app for you automatically.

	$ app2container -p 8080 myuser/container-name 1.2

External Buildpacks
-------------------

To add an external buildpack, you can specify it with a -b flag. For example, here is how to get hhvm working in a Docker container:

	$ app2container -b https://github.com/hhvm/heroku-buildpack-hhvm.git --from ctlc/buildstep:ubuntu12.04 wordpress

In this case, the standard hhvm buildpack is compiled against Ubuntu 12.04, whereas the default Linux distro in app2container is based on Ubuntu 12.10.

Creating Your Own Base Containers
---------------------------------

You can use https://github.com/progrium/buildstep as a starting point to build any container version you need for your applications. Here is how I built ctlc/buildstep:ubuntu12.04:

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

Adding Your Own Packages to the Standard Container
--------------------------------------------------

Sometimes, you don't need to modify the entire container OS, you may just need a few extra libraries:

	$ app2container -i "apt-get update && apt-get install -qy libapache2-mod-php5 php5-mysql php5-memcache php5-curl" wordpress

Or you can save your modifications to a file for a cleaner app2container command.

	$ echo "apt-get update && apt-get install -qy libapache2-mod-php5 php5-mysql php5-memcache php5-curl" > Dockerfile.include
	$ app2container -f Dockerfile.include wordpress


