FROM phusion/baseimage:0.9.16
MAINTAINER Harsh Vakharia <harshjv@gmail.com>
MAINTAINER Leandro Banchio <lbanchio@gmail.com>

# Default baseimage settings
ENV HOME /root
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh
CMD ["/sbin/my_init"]
ENV DEBIAN_FRONTEND noninteractive

# Update software list, install php-nginx & clear cache
RUN locale-gen en_US.UTF-8 && \
    export LANG=en_US.UTF-8 && \
    add-apt-repository -y ppa:ondrej/php && \
    apt-get update && \
    apt-get install -y --force-yes nginx \
    php5.6-fpm php5.6-zip php5.6-mysql php5.6-redis php5.6-mcrypt \
    php5.6-imagick php5.6-xml php5.6-xdebug php5.6-common \
    php5.6-sqlite git php5.6-http \
    php5.6-curl php5.6-gd php5.6-intl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* \
           /tmp/* \
           /var/tmp/*

# Configure nginx
RUN echo "daemon off;" >>                                               /etc/nginx/nginx.conf
RUN sed -i "s/sendfile on/sendfile off/"                                /etc/nginx/nginx.conf
RUN mkdir -p                                                            /var/www
RUN mkdir -p                                                            /run/php
RUN mkdir -m 777                                                        /tmp/php
RUN chown 33:33                                                         /run/php -R

# Configure PHP
RUN sed -i "s/;session.save_path =.*/session.save_path = \/tmp\/php/"   /etc/php/5.6/fpm/php.ini
RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/"                  /etc/php/5.6/fpm/php.ini
RUN sed -i "s/;date.timezone =.*/date.timezone = Asia\/Kolkata/"        /etc/php/5.6/fpm/php.ini
RUN sed -i "s/variables_order =.*/variables_order = \"EGPCS\"/"         /etc/php/5.6/fpm/php.ini
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g"                 /etc/php/5.6/fpm/php-fpm.conf
RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/"                  /etc/php/5.6/cli/php.ini
RUN sed -i "s/;date.timezone =.*/date.timezone = Asia\/Kolkata/"        /etc/php/5.6/cli/php.ini
RUN sed -i "s/;clear_env =.*/clear_env = no/"                           /etc/php/5.6/fpm/pool.d/www.conf

RUN phpenmod mcrypt
RUN phpenmod xdebug

# Add nginx service
RUN mkdir                                                               /etc/service/nginx
ADD build/nginx/run.sh                                                  /etc/service/nginx/run
RUN chmod +x                                                            /etc/service/nginx/run

# Add PHP service
RUN mkdir                                                               /etc/service/phpfpm
ADD build/php/run.sh                                                    /etc/service/phpfpm/run
RUN chmod +x                                                            /etc/service/phpfpm/run

RUN chmod 777                                                           /var/lib/php -R
# Add nginx
VOLUME ["/var/www", "/etc/nginx/sites-available", "/etc/nginx/sites-enabled"]

# Workdir
WORKDIR /var/www

EXPOSE 80
