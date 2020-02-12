FROM php:7.3-apache

# Update the system and install dev packages.
RUN apt-get update && \
    apt-get install -y \
        git \
        zip \
        curl \
        sudo \
        unzip

# mod_rewrite for URL rewrite and mod_headers for .htaccess extra headers
# like Access-Control-Allow-Origin
RUN a2enmod rewrite headers

# Start with base php config, then add extensions.
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"
RUN docker-php-ext-install \
    bz2 \
    intl \
    iconv \
    bcmath \
    opcache \
    mbstring \
    pdo_mysql \
    zip

# Composer.
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# We need a user with the same UID/GID with host user so when we execute CLI
# commands, all the host file's ownership remains intact. Otherwise command
# from inside container will create root-owned files and directories.
ARG uid
RUN useradd -G www-data,root -u $uid -d /home/devuser devuser
RUN mkdir -p /home/devuser/.composer && \
    chown -R devuser:devuser /home/devuser