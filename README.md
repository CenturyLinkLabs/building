app2container
==========
Build a Docker container for any app using Heroku Buildpacks

Usage
-----

To convert any app into a Docker container using Heroku Buildpacks, just use this simple gem.

	sudo gem install app2container
	app2container myuser/container-name

	docker run -d -p 8080 -e "PORT=8080" myuser/container-name

You can version your apps by adding a verison number.

	app2container myuser/container-name 1.2

	docker run -d -p 8080 -e "PORT=8080" myuser/container-name:1.2

Also, you can have app2container run the app for you automatically.

	app2container -p 8080 myuser/container-name 1.2

External Buildpacks
-------------------

To add an external buildpack, you can specify it with a -b flag. For example, here is how to get hhvm working in a Docker container:

	app2container -b https://github.com/hhvm/heroku-buildpack-hhvm.git --from ctlc/buildstep:ubuntu12.04 wordpress

In this case, the standard hhvm buildpack is compiled against Ubuntu 12.04, whereas the default Linux distro in app2container is based on Ubuntu 12.10.

Creating Your Own Base Containers
---------------------------------

You can use https://github.com/progrium/buildstep as a starting point to build any container version you need for your applications. Here is how I built ctlc/buildstep:ubuntu12.04:

	git clone https://github.com/progrium/buildstep.git
	cd buildstep
	echo "FROM ubuntu:lucid
	RUN apt-get update && apt-get install python-software-properties -y
	RUN apt-add-repository ppa:brightbox/ruby-ng
	RUN apt-get update && apt-get install git-core curl rubygems libmysqlclient-dev libxml2 libxslt1.1 libfreetype6 libjpeg-dev liblcms-utils libxt6 libltdl-dev -y
	RUN mkdir /build
	ADD ./stack/ /build
	RUN LC_ALL=C DEBIAN_FRONTEND=noninteractive /build/prepare
	RUN apt-get clean" > Dockerfile

	docker build -t ctlc/buildstep:ubuntu12.04 .
	docker push ctlc/buildstep
