fig2coreos
==========
Convert fig.yml to CoreOS formatted systemd configuration files

Usage
-----

To convert any fig.yml into a set of CoreOS configuration files (in /media/system/units) just point the command to your fig.yml file and a directory to put your coreos files in:

	sudo gem install fig2coreos
	fig2coreos app-name fig.yml coreos-dir

By default, fig2coreos will assume you are running this locally with vagrant and VirtualBox installed, so it will create a Vagrantfile which you can run vagrant up in and have a CoreOS running locally with the equivalent of your fig.yml running in it.

	cd coreos-dir
	vagrant up

The fig2coreos command auto-generates etcd discovery registration and fleet integration as well, so you can inspect your app easily.

	vagrant ssh
	$ fleetctl list-units

