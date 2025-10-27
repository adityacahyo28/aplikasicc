FROM php:8.2-cli

# Perbaikan: Menggabungkan semua instalasi paket dalam satu perintah RUN dengan line continuation (\)
RUN apt-get update && apt-get install -y \
    git \
    zip \
    unzip \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    && docker-php-ext-install pdo_mysql exif pcntl bcmath gd zip \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY . .

# Catatan: Perintah Composer ini redundan karena ada di Jenkinsfile, tapi aman untuk dibiarkan.
# Jika Anda ingin memisahkan build image (tanpa composer install) dari deploy (dengan composer install),
# hapus baris ini dan hanya jalankan di Jenkinsfile. Saya biarkan di sini untuk konsistensi.
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 8000

CMD php artisan serve --host=0.0.0.0 --port=8000
