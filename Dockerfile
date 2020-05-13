FROM alpine:3.11
MAINTAINER Jichan <development@jc-lab.net>

RUN apk --update add --no-cache python2 bash nginx supervisor openssh-server openssh-sftp-server php7-fpm php7-mcrypt php7-json php7-mysqli php7-iconv mariadb-client php7-ldap php7-curl php7-dom

# NGINX
RUN mkdir -p /run/nginx/ && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log
RUN sed -i 's/user = nobody/user = nginx/g' /etc/php7/php-fpm.d/www.conf && sed -i 's/group = nobody/group = nginx/g' /etc/php7/php-fpm.d/www.conf
COPY ["default.conf", "/etc/nginx/conf.d/default.conf"]

# SSH
RUN rm /etc/ssh/sshd_config && ln -s /data/ssh_keys /etc/ssh/keys
COPY ["sshd_config", "/etc/ssh/sshd_config"]

# Supervisord
ADD supervisord.ini /etc/supervisor.d/
ADD ["docker_kill.py", "entrypoint.sh", "/"]
RUN chmod +x /docker_kill.py && chmod +x /entrypoint.sh

# Configuration for Container
EXPOSE 22 80

# Optional
RUN apk --update add --no-cache php7-session

CMD ["/bin/sh", "-c", "/entrypoint.sh"]

