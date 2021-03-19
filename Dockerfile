FROM php:7.2.5-fpm

RUN apt-get update && apt-get install -y \
        apt-utils \
        supervisor \
        nginx \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
        wget \
        procps \
        libsqlite3-dev \
        zlib1g-dev \

    && docker-php-ext-install pdo_mysql pdo_sqlite mysqli gd json zip opcache \
    && EXPECTED_COMPOSER_SIGNATURE=$(wget -q -O - https://composer.github.io/installer.sig) \
    && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php -r "if (hash_file('SHA384', 'composer-setup.php') === '${EXPECTED_COMPOSER_SIGNATURE}') { echo 'Composer.phar Installer verified'; } else { echo 'Composer.phar Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php --install-dir=/usr/bin --filename=composer \
    && php -r "unlink('composer-setup.php');"

RUN apt-get update && \
    apt-get install -y gnupg && \
    curl -sL https://deb.nodesource.com/setup_12.x -o /nodesource_setup.sh && \
    chmod a+x /nodesource_setup.sh && \
    /nodesource_setup.sh && \
    apt-get install -y nodejs && \
    apt-get install -y libxml2-dev && \
    docker-php-ext-install soap && \
    apt-get install -y gconf-service libasound2 libatk1.0-0 libcairo2 libcups2 libfontconfig1 libgdk-pixbuf2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libxss1 fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils && \
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    dpkg -i google-chrome-stable_current_amd64.deb; apt-get -fy install && \
    rm google-chrome-stable_current_amd64.deb

RUN adduser --system --no-create-home --shell /bin/false --group --disabled-login nginx

ADD docker/supervisord.conf /etc/supervisord.conf
ADD docker/default.conf /etc/nginx/sites-enabled/default
ADD docker/www.conf /usr/local/etc/php-fpm.d/www.conf
ADD docker/start.sh /start.sh

RUN chmod a+x /start.sh

RUN apt-get install -y zlib1g-dev libicu-dev g++
RUN docker-php-ext-configure intl
RUN docker-php-ext-install intl

EXPOSE 443 80
WORKDIR /code

CMD ["/start.sh"]
