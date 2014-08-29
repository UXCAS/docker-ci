# Jenkins CI Docker Container

This repository contains the Docker configuration to deploy a Jenkins service with Android SDK and Ruby installed. This Docker specification has been successfully deployed to an Amazon Docker instance on Elastic beanstalk.

## Dockerfile dependancies

* plugins.txt - This file contains the desired plugins which should be installed on jenkins at deploy time
* versions.txt - This file lists the ruby versions that should be installed into the jenkins container
* keys/id_rsa & keys/id_rsa.pub - The ssh keys needed by Jenkins to work with github.
* .ebextensions - Needed to deploy to Amazon using the zip method in [elastic beanstalk](http://www.incrediblemolk.com/running-a-docker-container-on-aws-elastic-beanstalk/) it increased the timeout setting to stop elastic beanstalk quiting on you.


Once this Docker specification is deployed you should be able to run Android and Rails jobs on CI