set -ex
# SET THE FOLLOWING VARIABLES
# docker hub username
USERNAME=e4cash
# image name
IMAGE=middleware
# version wildfly
VERSION=8.5.31

docker build --tag=$IMAGE-tomcat-$VERSION -t $USERNAME/$IMAGE-tomcat-$VERSION:latest .

