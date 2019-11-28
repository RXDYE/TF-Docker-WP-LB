#!/bin/bash
#disabling selinux
sudo setenforce 0
RUN sed -i "s/SELINUX=enforcing/SELINUX=enforcing/" /etc/sysconfig/selinux

#docker setup
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum -y install docker-ce
sudo systemctl start docker
sudo systemctl enable docker

#pulling containers
sudo docker login $1 -p $2 -u $3
sudo docker pull $1/lb
sudo docker pull $1/wp

#running containers
sudo docker network create --driver bridge wp_lb_bridge
sudo docker run -d --net=wp_lb_bridge -p :80 --name wp1 $1/wp
sudo docker run -d --net=wp_lb_bridge -p :80 --name wp2 $1/wp
sudo docker run -d --net=wp_lb_bridge -p :80 --name wp3 $1/wp
sudo docker run -d --net=wp_lb_bridge -p 80:80 --name lb $1/lb