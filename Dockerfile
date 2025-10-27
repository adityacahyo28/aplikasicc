FROM php:8.2-cli

RUN apt-get update && apt-get install -y \
    git zip unzip curl libpng-dev libonig-dev libxml2-dev libzip-dev \
    # Perbaikan: 'mbstring' dihapus karena sudah ada di base image.
    && docker-php-ext-install pdo_mysql exif pcntl bcmath gd zip \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY . .

RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Perbaikan: Mengganti 'www-data' dengan 'root' jika menjalankan 'php artisan serve' di dalam container
# Jika Anda menjalankan php artisan serve, container biasanya berjalan sebagai root, bukan www-data.
# Namun, karena perintah sebelumnya menggunakan www-data, saya akan mengembalikan ownership ke www-data setelah composer, 
# kemudian menjalankan CMD dengan user 'root' yang merupakan default dari php:8.2-cli. 
# Jika Anda ingin menjalankan server sebagai user www-data, Anda harus menambahkan user directive dan menginstal supervisor/fpm.
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 8000

CMD php artisan serve --host=0.0.0.0 --port=8000
