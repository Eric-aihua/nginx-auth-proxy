Nginx authentication proxy
==========================

Simple proxy used to send the request using the proxy_pass directive to an authentication backend specified using the AUTH_BACKEND environment variable. Traffic that passes the authentication backend will then be sent to the backend specified using the BACKEND environment variable.

Running the docker container:
```
ubuntu@trusty-64:/nginx-auth# docker build -t nginx-auth
ubuntu@trusty-64:/nginx-auth# docker run -e AUTH_BACKEND=https://someauthapi -e BACKEND=http://youprivateregistry -p 0.0.0.0:8080:80 nginx-auth
```


How it works with private docker registry
=========================================

Below part can be put into `fig.yml`

```
docker rm -f registry
docker run -d --name registry -p 5000:5000 registry
docker run -d --link registry:docker-registry -p 8080:80 -p 1000:5000 larrycai/nginx-auth-proxy
```

Now we can start to use it HTTP+basic auth

```
docker@boot2docker:$ docker pull hello-world
docker@boot2docker:$ docker tag hello-world localhost:5000/hello-world
docker@boot2docker:$ docker push localhost:5000/hello-world
The push refers to a repository [localhost:5000/hello-world] (len: 1)
Sending image list
Pushing repository localhost:5000/hello-world (1 tags)
511136ea3c5a: Image successfully pushed
7fa0dcdc88de: Image successfully pushed
ef872312fe1b: Image successfully pushed
Pushing tag for rev [ef872312fe1b] on {http://localhost:5000/v1/repositories/hello-world/tags/latest}
docker@boot2docker:$ docker pull localhost:5000/hello-world
Pulling repository localhost:5000/hello-world
ef872312fe1b: Download complete
511136ea3c5a: Download complete
7fa0dcdc88de: Download complete
Status: Image is up to date for localhost:5000/hello-world:latest
docker@boot2docker:/c/Users/rdccaiy/git/docker/nginx-auth-proxy$ docker login -u larrycai -p passwd -e larry@email.com localhost:1000
Login Succeeded
docker@boot2docker:$ docker push localhost:1000/hello-world
The push refers to a repository [localhost:1000/hello-world] (len: 1)
Sending image list
Pushing repository localhost:1000/hello-world (1 tags)
511136ea3c5a: Pushing
2014/11/26 08:05:51 HTTP code 401, Docker will not send auth headers over HTTP.
```

Now we play with https+basic auth

```
docker build -t larrycai/nginx-auth-proxy .
docker rm -f registry nginx
docker run -d --name registry -p 5000:5000 registry
docker run -d --hostname dokk.co --name nginx --link registry:registry -p 443:443 larrycai/nginx-auth-proxy

# self service key
openssl genrsa -des3 -out server.key 2048
openssl req -new -key server.key -out server.csr # choose dokk.co for domain name
cp server.key server.key.org
openssl rsa -in server.key.org -out server.key
openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt

# verify
# open browser to access 192.168.59.103
sudo vi /etc/hosts  # append dokk.co in 127.0.0.1
curl -i -k https://larrycai:passwd@dokk.co
docker login -u larrycai -p passwd -e "test@gmail.com" dokk.co

