#!/bin/bash

echo -e "Enviroment: $ENVIROMENT"

#if ! $(wp --path=/usr/share/nginx/www core is-installed ); then
if [ ! -f /usr/share/nginx/www/wp-config.php ]; then
echo -e "Wordpress not installed in /usr/share/nginx/www"
  
  #mysql has to be started this way as it doesn't work to call from /etc/init.d
  
  MYSQL_HOST="localhost"
    echo -e "mysql host: \t$MYSQL_HOST" > ~/settings.txt
  MYSQL_ROOT_USER="root"
    echo -e "mysql root user:\t$MYSQL_ROOT_USER" >> ~/settings.txt
  MYSQL_ROOT_PASSWORD=`pwgen -c -n -1 12`
    echo -e "mysql root password:\t$MYSQL_ROOT_PASSWORD" >> ~/settings.txt
  WORDPRESS_DB="wpaplrwp"
    echo -e "wordpress db name:\t$WORDPRESS_DB" >> ~/settings.txt
  WORDPRESS_DB_USER="wpdbuser"
    echo -e "mysql wp db user:\t$WORDPRESS_DB_USER" >> ~/settings.txt
  WORDPRESS_DB_PASSWORD=`pwgen -c -n -1 12`
    echo -e "mysql wp db password:\t$WORDPRESS_DB_PASSWORD"  >> ~/settings.txt 
  WORDPRESS_ADMIN="applari"
    echo -e "wordpress admin pw:\t$WORDPRESS_ADMIN" >> ~/settings.txt
  WORDPRESS_ADMIN_PW=`pwgen -c -n -1 12`
    echo -e "wordpress admin pw:\t$WORDPRESS_ADMIN_PW" >> ~/settings.txt
  WORDPRESS_ADMIN_EMAIL="sovellukset@applari.fi"
    echo -e "wordpress admin email:\t$WORDPRESS_ADMIN_EMAIL" >> ~/settings.txt
  DB_PREFIX=`pwgen -1 -A -0 5`
    echo -e "wordpress db prefix:\t$DB_PREFIX" >> ~/settings.txt
  SITE_URL="http://docker.local"
    echo -e "wordpress site url:\t$SITE_URL" >> ~/settings.txt
  SITE_TITLE="Applari WordPress"
    echo -e "wordpress site title:\t$SITE_TITLE" >> ~/settings.txt
  SITE_ROOT="/usr/share/nginx/www"
    echo -e "wordpress site root:\t$SITE_ROOT" >> ~/settings.txt
  WP_CORE_DIR="wp"
    echo -e "wordpress core dir:\t$WP_CORE_DIR" >> ~/settings.txt

  cat ~/settings.txt

  /usr/bin/mysqld_safe &
  
  while ! mysqladmin ping -h"$MYSQL_HOST" --silent; do
    echo "Waiting for mysqld to start..."
    sleep 1
  done


  # Here we generate random passwords (thank you pwgen!). The first two are for mysql users, the last batch for random keys in wp-config.php
  #This is so the passwords show up in logs.
  

  # create db and privileges
    echo -e mysqladmin -u $MYSQL_ROOT_USER -h $MYSQL_HOST password $MYSQL_ROOT_PASSWORD
  mysqladmin -u $MYSQL_ROOT_USER -h $MYSQL_HOST password $MYSQL_ROOT_PASSWORD
    echo -e mysql -u$MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD -h$MYSQL_HOST -e "GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_ROOT_USER'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD' WITH GRANT OPTION;"
  mysql -u$MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD -h$MYSQL_HOST -e "GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_ROOT_USER'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD' WITH GRANT OPTION;"
    echo -e mysql -u$MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD -h$MYSQL_HOST -e "FLUSH PRIVILEGES;"
  mysql -u$MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD -h$MYSQL_HOST -e "FLUSH PRIVILEGES;"

    # add wordpress db user and privileges.
  #  echo -e mysql -u$MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD -h$MYSQL_HOST -e "GRANT ALL PRIVILEGES ON $WORDPRESS_DB.* TO '$WORDPRESS_DB_USER'@'$MYSQL_HOST' IDENTIFIED BY '$WORDPRESS_DB_PASSWORD';" 
  #mysql -u$MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD -h$MYSQL_HOST -e "GRANT ALL PRIVILEGES ON $WORDPRESS_DB.* TO '$WORDPRESS_DB_USER'@'$MYSQL_HOST' IDENTIFIED BY '$WORDPRESS_DB_PASSWORD';" 
  #  echo -e mysql -u$MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD -h$MYSQL_HOST -e "FLUSH PRIVILEGES;"
  #mysql -u$MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD -h$MYSQL_HOST -e "FLUSH PRIVILEGES;"

  cd $SITE_ROOT
  mkdir $SITE_ROOT/$WP_CORE_DIR
  #mkdir $SITE_ROOT/content
  cd $SITE_ROOT/$WP_CORE_DIR

  #download core
  wp core download

  cd $SITE_ROOT
  
  # create wp-config
  wp core config --dbhost=$MYSQL_HOST --dbname=$WORDPRESS_DB --dbprefix=$DB_PREFIX --dbuser=$MYSQL_ROOT_USER --dbpass=$MYSQL_ROOT_PASSWORD --path=$SITE_ROOT/$WP_CORE_DIR --extra-php <<PHP
    define( 'WP_DEBUG', true );
    define( 'WP_DEBUG_LOG', true );


    define('WP_SITEURL', '$SITE_URL/wp');
    define('WP_HOME', '$SITE_URL/');
    //define('RELOCATE', true);

    
    //define ('WP_CONTENT_FOLDERNAME', 'content');
    //define( 'WP_CONTENT_DIR',  "$SITE_ROOT/" . WP_CONTENT_FOLDERNAME );

    //define( 'WP_CONTENT_URL', '$SITE_URL/'.WP_CONTENT_FOLDERNAME );

    define( 'WP_AUTO_UPDATE_CORE', false );
    define( 'AUTOMATIC_UPDATER_DISABLED', true );
PHP
 
  #cp -r $SITE_ROOT/$WP_CORE_DIR/wp-content/ $SITE_ROOT/content/
  #rm -rf $SITE_ROOT/$WP_CORE_DIR/wp-content

  #chmod 644 wp-config.php


  #create wordpress db 
  wp db create --path=$SITE_ROOT/$WP_CORE_DIR

  # install WordPress 
  #echo wp core install --title='"$SITE_TITLE"' --url=$SITE_URL --admin_user=$WORDPRESS_ADMIN --admin_password=$WORDPRESS_ADMIN_PW --admin_email=$WORDPRESS_ADMIN_EMAIL --path=$SITE_ROOT/$WP_CORE_DIR
  wp core install --title='"SITE_TITLE"' --url=$SITE_URL --admin_user=$WORDPRESS_ADMIN --admin_password=$WORDPRESS_ADMIN_PW --admin_email=$WORDPRESS_ADMIN_EMAIL --path=$SITE_ROOT/$WP_CORE_DIR --skip-email

  # Copy (not move) index.php file to root
  cp $SITE_ROOT/$WP_CORE_DIR/index.php $SITE_ROOT/

  # Edit index.php to point to correct path of wp-blog-header.php
  sed -i "s/\/wp-blog-header/\/$WP_CORE_DIR\/wp-blog-header/g" $SITE_ROOT/index.php

  # Update the siteurl in the database with sub directory path
  wp option update siteurl $(wp option get siteurl)/$WP_CORE_DIR --path=$SITE_ROOT/$WP_CORE_DIR

  #copy wp-config to site root
  #cp "$SITE_ROOT/$WP_CORE_DIR/wp-config.php" ./wp-config.php
  mv "$SITE_ROOT/$WP_CORE_DIR/wp-config.php" ./wp-config.php

  # Download nginx helper plugin
  wp plugin install nginx-helper --activate --path=$SITE_ROOT/$WP_CORE_DIR

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
