FROM debian:bookworm-slim
RUN apt-get update \
 && apt-get install -y --no-install-recommends nginx openssl \
 && rm -rf /var/lib/apt/lists/* \
 && rm -f /etc/nginx/sites-enabled/default
COPY thm.conf /etc/nginx/conf.d/thm.conf
EXPOSE 80 443
CMD ["nginx", "-g", "daemon off;"]
