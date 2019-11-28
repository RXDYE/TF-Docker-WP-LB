FROM centos:7

ARG DB_NAME
ARG DB_USER
ARG DB_PASSWORD
ARG DB_HOST

#install httpd
RUN yum -y install httpd

#install php-modules for wp
RUN yum -y install epel-release && \
    yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm && \
    yum-config-manager --enable remi-php73 && \
    yum -y install php php-mysql php-gd wget

RUN wget -q -O - "http://wordpress.org/latest.tar.gz" | tar -xzf - -C /var/www/html
RUN chown -R apache /var/www/html

COPY wp-config.php /var/www/html/wordpress/
RUN sed -i "s/define('DB_NAME', '');/define('DB_NAME', '${DB_NAME}');/" /var/www/html/wordpress/wp-config.php
RUN sed -i "s/define('DB_USER', '');/define('DB_USER', '${DB_USER}');/" /var/www/html/wordpress/wp-config.php
RUN sed -i "s/define('DB_PASSWORD', '');/define('DB_PASSWORD', '${DB_PASSWORD}');/" /var/www/html/wordpress/wp-config.php
RUN sed -i "s/define('DB_HOST', '');/define('DB_HOST', '${DB_HOST}');/" /var/www/html/wordpress/wp-config.php
COPY lb.php /var/www/html
EXPOSE 80
CMD ["/usr/sbin/httpd","-D","FOREGROUND"]
