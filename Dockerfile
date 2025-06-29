# Gunakan image PHP-FPM standar sebagai basis
FROM php:8.3-fpm-alpine

# Atur working directory di dalam container
WORKDIR /var/www/html

# Copy kode aplikasi Laravel-mu ke dalam container
COPY . /var/www/html

# UBAH 'listen' directive di konfigurasi pool PHP-FPM
# agar mendengarkan di IP 0.0.0.0
RUN sed -i 's/listen = 127.0.0.1:9000/listen = 0.0.0.0:9000/g' /usr/local/etc/php-fpm.d/www.conf

# Instal Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Instal dependensi Composer
RUN composer install --no-dev --optimize-autoloader

# Hapus cache konfigurasi Laravel (penting agar variabel lingkungan CapRover terbaca)
RUN php artisan config:clear

# Buat cache aplikasi Laravel
RUN php artisan optimize

# Pastikan hak akses file dan folder untuk Laravel
RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Paparkan port PHP-FPM
EXPOSE 9000

# Jalankan PHP-FPM
CMD ["php-fpm"]
