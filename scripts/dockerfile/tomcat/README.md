docker pull alpine
docker image inspect alpine:latest|grep alpine:

docker pull ubuntu:18.04

#for i in `docker images|grep "<none>"|awk '{ print $3 }'`; do docker image rm $i; done
#for i in `docker images|grep "ope-222"|awk '{ print $3 }'`; do docker image rm $i; done
#for i in `docker images|grep "ora-201"|awk '{ print $3 }'`; do docker image rm $i; done

docker build -f openjdk8.dfile -t myjdk:ope-222 .
docker build -f oraclejdk8.dfile -t myjdk:ora-201 .

docker run -it --rm myjdk:ope-222
docker run -it --rm myjdk:ora-201

#for i in `docker images|grep "ora-201"|awk '{ print $3 }'`; do docker image rm $i; done

docker build -f tomcat-ope-8.dfile -t tomcat8:ope-8 .
docker run -itP --rm tomcat8:ope-8
