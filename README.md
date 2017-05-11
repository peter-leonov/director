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

    ./deploy.sh test-machine demo vXXXX

where `XXXX` is any version name / number you like, for ex. `v123` for a Jira ticket PN-123.



# Fin!

Enjoy this little big deploy architecture and share your thoughts!
