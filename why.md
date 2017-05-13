---
title: "Docker based A/B testing and demo servers"
description: "A/B testing with Blue-Green Deployment"
categories: [backend, docker, git]
layout: post
lang: en
---

TL;DR: A sample project ready to get deployed (with descriptive REAMDE): [github.com/peter-leonov/director](https://github.com/peter-leonov/director)

A/B testing without proper tooling can lead to a mess in code and in mind like source control without Git would do. If your Docker infrastructure is mature enough to be called truly dockerized then you are already prepared. With Docker Compose it is really easy to deploy your application using Blue-Green Deployment which could be used also for split testing, performance QA, beta releases and what not. In this post I would like to share the minimalistic setup I've been using since early 2015 once fall in love with Docker.


## Prerequisites

The App should meet a few requirements:

1. Be truly dockerized
2. Has a [Single Entry Point](https://www.nginx.com/blog/12-reasons-why-nginx-is-the-standard-for-containerized-applications-and-deploying-microservices/)
3. Meet the [Config Factor](https://12factor.net/config) of [The Twelve-Factor App](https://12factor.net).

Most apps which could be run using just a `docker-compose up` command would be highly possibly  ready for the technique described in this post.


## Idea behind this post

Since mid 2015 Docker allows us create [user defined networks](https://docs.docker.com/engine/userguide/networking/#user-defined-networks) which in turn allow to fully isolate (of cause, except for limited resources, such as CPU, disk space, memory, etc.) any application within a single machine or a Docker Swarm. Having an App set up to get run inside of a user defined network allows many App versions to live together in the same box without even a single configuration file changed.

A aser defined network is the very same thing as the `default` Docker network except for a little bit different semantics for resolving host names. If you have been using `docker-compose.yaml` files of version 2 or higher then your app is already using a user defined network automatically created by Docker Compose. This allows run containers to see and connect to each other using their service names without all that long port number environment variables and [container linking](https://docs.docker.com/engine/userguide/networking/default_network/dockerlinks/) stuff from docker 0.6.


## The trick

As of version 3 the `docker-compose.yaml` in addition to a ready to run App Docker Compose allows also to configure a ready to deploy app if you specify `build` and `image` in a service sections simultaneously. This enables `docker-compose` command to know how to properly tag and push build container images. Also, using recently added and made stable environment variables substitution one could use `docker-compose` command to deploy the same application to different environments changing only environment variables withing a simple bash script. No Chef / Puppet knowledge required, only bash and Docker only hardcore. To also make the deployed application URL look good and fit it for, say, SSL termination, we will use a simple nginx config to reverse proxy to a specific version based on a specified host name. Yeap, this is the whole trick. For performance reasons I have chosen to build images using local docker daemon as the expected deploy target may not have enough memory or CPU to flawlessly build, say, a huge native requirement of a node.js module.


## The actual code

Here is [a sample project](https://github.com/peter-leonov/director) which you could clone and run yourself. All the steps you need to take to get it running are described in the README. In real world case you also would need to tune your DNS server to point to the docker machine / swarm IP using wild-card `A` record.


## Benefits

1. Real zero downtime deployment for Frontend as all the assets will get loaded using versioned hostnames (like `v123.example.com`) and no race condition would be possible when a user gets `app.js` for version **A** – deploy happens here – and the same user gets `app.css` for the newly deployed version **B**.

2. Split testing made dump simple: deploy the beta version to `v123.example.com` and split between it and `www.example.com` using any technique you like. If `v123.example.com` shows better results all you need to do is just to re-deploy it to `www.example.com`.

3. Versions management made declaratively in Git: have a separated branch for each variant you test, no need to manually merge variant code removing all the `if`s in code, just use `git merge variant_branch`.

4. Demo / staging environments as close to production as you wish for free. Just deploy a feature branch to `v123.example.com`. I like to put there Jira ticket number and automatically link it to the ticket for PM to have a look.
