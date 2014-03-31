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

To add an external buildpack, you can specify that with the -b flag: