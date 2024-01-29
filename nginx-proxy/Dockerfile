FROM nginx

ARG proxy_host=go-web
ARG port=8888

COPY default.conf /etc/nginx/conf.d

RUN sed -i "s|#PROXY_HOST#|${proxy_host}|;s|#PORT#|${port}|" /etc/nginx/conf.d/default.conf
