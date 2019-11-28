# This is terraform deployment of docker LAMP&nginx loadbalancing containers to Microsoft Azure
Building lamp container(wordpress):
```
docker build -t wp --build-arg DB_NAME=s --build-arg DB_USER=s --build-arg DB_PASSWORD=s --build-arg DB_HOST=s .
```
Then build nginx loadbalancer
```
docker build -t lb .
```
**Before running _terraform apply_ all containers have to be tagged and pushed to the container registry specified in _vars.tf_!**