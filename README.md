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

```
docker rm -f backend
docker rm -f auth
docker run -d --name backend -p 5000:5000 registry
docker run -d --name auth opendns/basic-auth-service
auth_ip=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' auth)
backend_ip=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' backend)
docker run -d -e AUTH_BACKEND=http://$auth_ip:8000 -e BACKEND=http://$backend_ip:5000 -p 8080:80 -p 1000:5000 larrycai/nginx-auth-proxy
```