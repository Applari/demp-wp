FROM ubuntu:14.04
MAINTAINER Esa Heiskanen <esa@applari.fi>

# Keep upstart from complaining
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl

# Let the conatiner know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

#ENV

RUN apt-get update
RUN apt-get -y upgrade

# Basic Requirements
RUN apt-get -y install mysql-server mysql-client nginx php5-fpm php5-mysql php-apc pwgen python-setuptools curl git unzip 

# Wordpress Requirements
RUN apt-get -y install php5-curl php5-gd php5-intl php-pear php5-imagick php5-imap php5-mcrypt php5-memcache php5-ming php5-ps php5-pspell php5-recode php5-sqlite php5-tidy php5-xmlrpc php5-xsl sendmail ssmtp

# mysql config
RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf
# RUN mysqladmin -u root password mysecretpasswordgoeshere


# nginx config
RUN sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf
RUN sed -i -e"s/keepalive_timeout 2/keepalive_timeout 2;\n\tclient_max_body_size 100m/" /etc/nginx/nginx.conf
RUN echo "daemon off;" >> /etc/nginx/nginx.conf 

# php-fpm config
RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php5/fpm/php.ini
RUN sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 100M/g" /etc/php5/fpm/php.ini
RUN sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 100M/g" /etc/php5/fpm/php.ini
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf
RUN sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" /etc/php5/fpm/pool.d/www.conf
RUN find /etc/php5/cli/conf.d/ -name "*.ini" -exec sed -i -re 's/^(\s*)#(.*)/\1;\2/g' {} \;

# nginx site conf
ADD ./nginx-site.conf /etc/nginx/sites-available/default
RUN touch /var/log/php5-fpm.log

#sendmail
RUN echo "FromLineOverride=YES" >> /etc/ssmtp/ssmtp.conf && \
  	echo 'sendmail_path = "/usr/sbin/ssmtp -t"' > /usr/local/etc/php/conf.d/mail.ini

# Supervisor Config
RUN /usr/bin/easy_install supervisor
RUN /usr/bin/easy_install supervisor-stdout
ADD ./supervisord.conf /etc/supervisord.conf

# Wordpress Initialization and Startup Script
RUN mkdir /usr/share/nginx/www
RUN mkdir /usr/share/nginx/www/wp
#RUN mkdir /usr/share/nginx/www/content
RUN chown -R www-data:www-data /usr/share/nginx/www

# Add WP-CLI 
RUN curl -o /usr/local/sbin/wp-cli.phar https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
COPY wp-su.sh /usr/local/sbin/wp
RUN chmod +x /usr/local/sbin/wp-cli.phar
RUN chmod +x /usr/local/sbin/wp

# fix ubuntu ssh 
RUN echo "    IdentityFile ~/.ssh/id_rsa" >> /etc/ssh/ssh_config

# private expose
#EXPOSE 3306
EXPOSE 80:80

# volume for mysql database and wordpress install
# VOLUME ["/var/lib/mysql", "/usr/share/nginx/www"]
# VOLUME ["/usr/share/nginx/www"]

ADD ./start.sh /usr/local/sbin/start.sh
RUN chmod 755 /usr/local/sbin/start.sh

CMD ["/bin/bash", "-c","/usr/local/sbin/start.sh"]
