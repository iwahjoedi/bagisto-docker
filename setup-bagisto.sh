# Bagisto Account
# account: 
# admin@admin@example.com:admin123

compose_file='dev-apache-docker-compose.yml'
gitpod_80=$(gp url 80)  
sed -i "/APP_URL/c\APP_URL=${gitpod_80}" ".configs/.env"

# just to be sure that no traces left
docker-compose -f ${compose_file} down -v

# building and running docker-compose file
docker-compose -f ${compose_file} build && docker-compose -f ${compose_file} up -d

# container id by image name
apache_container_id=$(docker ps -aqf "name=bagisto-php-apache")
db_container_id=$(docker ps -aqf "name=bagisto-mysql")

echo "$apache_container_id" > apache_container_id
echo "$db_container_id" > db_container_id

# checking connection
echo "Please wait... Waiting for MySQL connection..."
while ! docker exec ${db_container_id} mysql --user=root --password=root -e "SELECT 1" >/dev/null 2>&1; do
    sleep 1
done

# creating empty database
echo "Creating empty database..."
while ! docker exec ${db_container_id} mysql --user=root --password=root -e "CREATE DATABASE IF NOT EXISTS bagisto CHARACTER SET utf8mb3 COLLATE utf8_unicode_ci;" >/dev/null 2>&1; do
    sleep 1
done

# setting up bagisto
# echo "Now, setting up Bagisto..."
# docker exec ${apache_container_id} git clone https://github.com/bagisto/bagisto
docker cp ../bagisto ${apache_container_id}:/var/www/html/
docker cp ../laravel-pwa ${apache_container_id}:/var/www/html/


# setting bagisto stable version
# echo "Now, setting up Bagisto stable version..."
# docker exec -i ${apache_container_id} bash -c "cd bagisto && git reset --hard $(git describe --tags $(git rev-list --tags --max-count=1))"

# installing composer dependencies inside container
docker exec -i ${apache_container_id} bash -c "cd bagisto && composer install"

# moving `.env` file
docker cp .configs/.env ${apache_container_id}:/var/www/html/bagisto/.env

# executing final commands
## Bagisto
# docker exec -i ${apache_container_id} bash -c "cd bagisto && php artisan optimize:clear && php artisan migrate:fresh --seed && php artisan storage:link && php artisan bagisto:publish --force && php artisan optimize:clear"
docker exec -i ${apache_container_id} bash -c "cd bagisto && php artisan optimize:clear"
docker exec -i ${apache_container_id} bash -c "cd bagisto && php artisan migrate:fresh --seed"
docker exec -i ${apache_container_id} bash -c "cd bagisto && php artisan storage:link"
docker exec -i ${apache_container_id} bash -c "cd bagisto && php artisan bagisto:publish --force"
docker exec -i ${apache_container_id} bash -c "cd bagisto && php artisan optimize:clear"

## Bagisto PWA
# docker exec -i ${apache_container_id} bash -c "cd bagisto && composer require bagisto/pwa:dev-master"
docker exec -i ${apache_container_id} bash -c "cd bagisto && php artisan config:cache"
docker exec -i ${apache_container_id} bash -c "cd bagisto && php artisan migrate"
docker exec -i ${apache_container_id} bash -c "cd bagisto && php artisan route:cache"
docker exec -i ${apache_container_id} bash -c "cd bagisto && php artisan vendor:publish --all"