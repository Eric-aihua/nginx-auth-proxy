#!/bin/bash

NGINX=/usr/local/nginx

# pystache "`cat ${NGINX}/conf/docker-registry.conf.template`" "{\"backend\":\"${BACKEND}\"}" > ${NGINX}/conf/docker-registry.conf

${NGINX}/sbin/nginx
