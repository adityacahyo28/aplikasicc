FROM php:8.2-cli

# Setting ENV agar tidak perlu interaksi manual saat instalasi
ENV DEBIAN_FRONTEND noninteractive

# --- Instalasi Dependensi dan Ekstensi PHP dalam satu layer ---
# Ini penting untuk efisiensi layer caching Docker
RUN apt-get update \
    # Install paket sistem yang diperlukan untuk PHP dan aplikasi
    && apt-get install -y --no-install-recommends \
        git \
        zip \
        unzip \
        curl \
        libpng-dev \
        libonig-dev \
        libxml2-dev \
        libzip-dev \
        libicu-dev \
        wget \
    \
    # Instal ekstensi PHP yang diperlukan
    # mbstring dan intl sangat penting untuk Laravel
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
    # Aktifkan Opcache untuk performa yang lebih baik (hanya aktif jika menggunakan FPM/Web server, tapi aman di CLI)
    && docker-php-ext-enable opcache \
    \
    # Hapus cache dan file yang tidak diperlukan untuk mengurangi ukuran image
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && rm -f /etc/php/*/conf.d/docker-php-ext-opcache.ini

# Salin Composer dari image resminya
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set direktori kerja aplikasi
WORKDIR /var/www/html

# Salin kode aplikasi ke dalam container
COPY . .

# Catatan: Perintah Composer ini menjalankan instalasi dependensi
# Sebaiknya dijalankan setelah semua kode disalin
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Perbaiki izin direktori storage dan cache yang diperlukan oleh Laravel
# Aplikasi akan berjalan sebagai user www-data (default user PHP di image ini)
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Atur user agar perintah selanjutnya (terutama CMD) berjalan dengan hak akses yang benar
USER www-data

# Port yang diekspos (sesuai dengan perintah artisan serve)
EXPOSE 8000

# Perintah default untuk menjalankan server pengembangan Laravel
# Jika ini untuk produksi, ganti base image ke php:8.2-fpm dan gunakan Nginx/Apache
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
