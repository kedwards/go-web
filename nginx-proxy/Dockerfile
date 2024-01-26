FROM nginx

ARG service=go-rest-service

ARG port=8888

COPY default.conf /etc/nginx/conf.d

RUN sed -i "s|#SERVICE#|${service}|;s|#PORT#|${port}|" /etc/nginx/conf.d/default.conf
