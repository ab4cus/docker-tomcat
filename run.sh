set -ex
# run docker
#docker run -m 1GB -p 80:80 -p 9990:9990 -d e4cash/middleware-wildfly-12.0.0:latest --hostname=core.test.e4-cash.net
#docker run --name=wildfly12-users -m 1.5GB -p 80:80 -p 9990:9990 -d e4cash/middleware-wildfly-12.0.0:latest 
#docker run -it wildfly -m 1024m
docker run  --name=tomcat8-sso \
			--network-alias=sso \
			--hostname=sso.e4cash.local \
			--link=sso:sso \
			--add-host=sso.e4cash.local:172.0.0.1 \
				-m 512MB \
				-p 8080:8080 \
				-v .:/opt/tomcat/webapps \
				-d e4cash/middleware-tomcat-8.5.31:latest

# env test
#docker run --name=tomcat8-users -m 1.5GB -p 8080:8080 -p 8009:8009 -v /opt/tomcat/webapps:/opt/tomcat/webapps -d e4cash/middleware-tomcat-8.0.49:latest

sleep 5

docker ps -a
