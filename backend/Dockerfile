FROM php:8.3-cli-alpine

WORKDIR /var/www/html

# Install system dependencies and build libraries
RUN apk add --no-cache \
    postgresql-dev \
    libzip-dev \
    zip \
    unzip \
    curl \
    git \
    linux-headers

# Install PHP PostgreSQL extensions
RUN docker-php-ext-install pdo pdo_pgsql pgsql pcntl bcmath

# Copy composer from official image
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy application files
COPY . .

# Set permissions for storage & bootstrap cache
RUN chmod -R 775 storage bootstrap/cache || true

# Run composer install if composer.json exists
RUN if [ -f composer.json ]; then \
        composer install --no-dev --prefer-dist --no-interaction --optimize-autoloader --ignore-platform-reqs || true; \
    fi

EXPOSE 8000

HEALTHCHECK --interval=10s --timeout=5s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/api/health || exit 1

CMD ["php", "-S", "0.0.0.0:8000", "-t", "public"]
