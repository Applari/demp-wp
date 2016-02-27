#!/bin/bash

echo -e "Enviroment: $ENVIROMENT"

#if ! $(wp --path=/usr/share/nginx/www core is-installed ); then
if [ ! -f /usr/share/nginx/www/wp-config.php ]; then
echo -e "Wordpress not installed in /usr/share/nginx/www"
  
  #mysql has to be started this way as it doesn't work to call from /etc/init.d
  
  MYSQL_HOST="localhost"
  MYSQL_ROOT_USER="root"
  MYSQL_ROOT_PASSWORD=`pwgen -c -n -1 12`
  WORDPRESS_DB="wpaplrwp"
  WORDPRESS_DB_USER="wpdbuser"
  WORDPRESS_DB_PASSWORD=`pwgen -c -n -1 12`
  DB_PREFIX=`pwgen -1 -A -0 5`
  #WORDPRESS_USER="applari"

  /usr/bin/mysqld_safe &
  
  while ! mysqladmin ping -h"$MYSQL_HOST" --silent; do
    echo "Waiting for mysqld to start..."
    sleep 1
  done


  # Here we generate random passwords (thank you pwgen!). The first two are for mysql users, the last batch for random keys in wp-config.php
  #This is so the passwords show up in logs.
  echo -e "mysql root user:\t$MYSQL_ROOT_USER" > ~/settings.txt
  echo -e "mysql root password:\t$MYSQL_ROOT_PASSWORD" >> ~/settings.txt
  echo -e "wordpress db name:\t$WORDPRESS_DB" >> ~/settings.txt
  echo -e "wordpress db prefix:\t$DB_PREFIX" >> ~/settings.txt
  echo -e "mysql wp db user:\t$WORDPRESS_DB_USER" >> ~/settings.txt
  echo -e "mysql wp db password:\t$WORDPRESS_DB_PASSWORD"  >> ~/settings.txt 
  cat ~/settings.txt

  # create db and privileges
  echo -e mysqladmin -u $MYSQL_ROOT_USER -h $MYSQL_HOST password $MYSQL_ROOT_PASSWORD
  mysqladmin -u $MYSQL_ROOT_USER -h $MYSQL_HOST password $MYSQL_ROOT_PASSWORD
  echo -e mysql -u$MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD -h$MYSQL_HOST -e "GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_ROOT_USER'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD' WITH GRANT OPTION;"
  mysql -u$MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD -h$MYSQL_HOST -e "GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_ROOT_USER'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD' WITH GRANT OPTION;"
  echo -e mysql -u$MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD -h$MYSQL_HOST -e "FLUSH PRIVILEGES;"
  mysql -u$MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD -h$MYSQL_HOST -e "FLUSH PRIVILEGES;"
  echo -e mysql -u$MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD -h$MYSQL_HOST -e "CREATE DATABASE $WORDPRESS_DB;"
  mysql -u$MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD -h$MYSQL_HOST -e "CREATE DATABASE $WORDPRESS_DB;"
  echo -e mysql -u$MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD -h$MYSQL_HOST -e "GRANT ALL PRIVILEGES ON $WORDPRESS_DB.* TO '$WORDPRESS_DB_USER'@'$MYSQL_HOST' IDENTIFIED BY '$WORDPRESS_DB_PASSWORD';" 
  mysql -u$MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD -h$MYSQL_HOST -e "GRANT ALL PRIVILEGES ON $WORDPRESS_DB.* TO '$WORDPRESS_DB_USER'@'$MYSQL_HOST' IDENTIFIED BY '$WORDPRESS_DB_PASSWORD';" 
  echo -e mysql -u$MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD -h$MYSQL_HOST -e "FLUSH PRIVILEGES;"
  mysql -u$MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD -h$MYSQL_HOST -e "FLUSH PRIVILEGES;"

  # Install wordpress with wp-cli
  cd /usr/share/nginx/www
  wp core download
  wp core config --dbhost=$MYSQL_HOST --dbname=$WORDPRESS_DB --dbprefix=$DB_PREFIX --dbuser=$WORDPRESS_DB_USER --dbpass=$WORDPRESS_DB_PASSWORD
  chmod 644 wp-config.php
  #wp core install --title="dev" --url="url" --admin_user=$WORDPRESS_USER --admin_password=$WORDPRESS_DB_PASSWORD --admin_email=sovellukset@applari.fi
  
  
  # Download nginx helper plugin
  wp plugin install nginx-helper --activate

  # create print out ssh public key
  ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
  echo -e "Add following key to jelastic\n"
  echo -e "---\n" 
  cat ~/.ssh/id_rsa.pub
  echo -e "---\n"
 
  killall mysqld
else
  echo -e "Wordpress already installed - skip init"
fi

# start all the services
/usr/local/bin/supervisord -n
