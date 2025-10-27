FROM php:8.2-cli

# Setting ENV agar tidak perlu interaksi manual saat instalasi
ENV DEBIAN_FRONTEND noninteractive

# --- Instalasi Dependensi dan Ekstensi PHP ---
# Memastikan semua dependensi build (termasuk g++ untuk intl) terinstal
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        zip \
        unzip \
        curl \
        wget \
        g++ \
        pkg-config \
        libpng-dev \
        libonig-dev \
        libxml2-dev \
        libzip-dev \
        libicu-dev \
    \
    # Instalasi dan Aktivasi Ekstensi PHP
    && docker-php-ext-install \
        pdo_mysql \
        exif \
        pcntl \
        bcmath \
        gd \
        zip \
        mbstring \
        intl \
    \
    # Optimasi dan Pembersihan
    && docker-php-ext-enable opcache \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Salin Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set direktori kerja aplikasi di dalam container
WORKDIR /var/www/html

# --- PERBAIKAN UTAMA DI SINI ---
# Ganti './app' dengan nama subdirektori folder Laravel Anda jika berbeda!
# Contoh: Jika folder Laravel Anda ada di root, gunakan COPY . .
# Jika folder Laravel Anda ada di './laravel-app', gunakan COPY ./laravel-app .
COPY ./app .

# Jalankan Composer install
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Perbaikan Izin Berkas
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Turunkan ke user non-root
USER www-data

# Port yang diekspos
EXPOSE 8000

# Perintah default untuk menjalankan server pengembangan Laravel
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
