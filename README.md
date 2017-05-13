This is a template project for those who want to have a simple docker environment for A/B testing, demo servers, Blue-Green Deployments for Frontend, and true staging out of the box. This all is build in Docker and is the reason for the Docker phenomenon to exists.

More in a separate inspiring article: [why.md](why.md).



# Initial setup

## Docker

To run this sample project we would need to set up local docker and at least one docker machine.

On Mac OS it's simple: just install [Docker for Mac](https://docs.docker.com/docker-for-mac/install/) and create a test machine with `docker-machine create test-machine`.

Also you would need to login to your Docker Hub account to be able to push containers to the Registry. Run `docker login` and follow the instructions.


## Config

Finally, please, change `DOCKER_USER` environment variable to your own in `setup.sh` and `deploy.sh`. And also rename all the `example.com` entries to what's appropriate for your project.


## Infrastructure

To set up infrastructure run `./setup.sh MACHINE_NAME`. This will create a shared user defined network and a **Director** container with nginx set up to proxy to proper App version.

    cd infrastructure
    ./setup.sh test-machine

To test if the infrastructure has been correctly set up, run this:

    export TEST_MACHINE_IP=$(docker-machine ip test-machine)
    curl -i http://$TEST_MACHINE_IP:90/
    curl -i http://$TEST_MACHINE_IP:80/

First one (on port `90`) should redirect you to `https://%IP%` and second one (on port `80`) should redirect to `https://www.example.com/`.



# Deploy

As simple as:

    ./deploy.sh test-machine demo XXXX

where `XXXX` is any version name / number you like, for ex. `pn123` for a Jira ticket PN-123, and `demo` is the environment file to use.

When you need to deploy master version, run this:

    ./deploy.sh test-machine production master

If the deploy script run successfully test the variant with:

    export TEST_MACHINE_IP=$(docker-machine ip test-machine)
    # for production / master
    curl -i -H 'Host: www.example.com' http://$TEST_MACHINE_IP/
    # for demo / pn123
    curl -i -H 'Host: pn123.demo.example.com' http://$TEST_MACHINE_IP/

If you do not want to use the `TEST_MACHINE_IP` variable every time and also would like to test you App in browser (for whatever reason) just add the IP to your `/etc/hosts` like this:

    192.168.99.100 example.com www.example.com pn123.demo.example.com

To reclaim disk space used by old garbage containers and images run from time to time this command: `docker system prune -f`. It might remove something useful which you do not expect, so first, please, make sure you know what this command is doing.



# Debug

If you want to just run Compose locally w/o separating building / pushing / running, then start you app on a local Docker daemon using command `./run.sh demo`. This will run everything on your machine with stub environment varables.



# Fin!

Enjoy this little big deploy architecture and share your thoughts!

In case of troubles, here is the `docker version` output for a setup this project has been tested on:

    Client:
     Version:      17.03.1-ce
     API version:  1.27
     Go version:   go1.7.5
     Git commit:   c6d412e
     Built:        Tue Mar 28 00:40:02 2017
     OS/Arch:      darwin/amd64

    Server:
     Version:      17.03.1-ce
     API version:  1.27 (minimum version 1.12)
     Go version:   go1.7.5
     Git commit:   c6d412e
     Built:        Fri Mar 24 00:00:50 2017
     OS/Arch:      linux/amd64
     Experimental: true

