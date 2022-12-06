## Update Bagisto Only

compose_file='dev-apache-docker-compose.yml'
gitpod_80=$(gp url 80)  
sed -i "/APP_URL/c\APP_URL=${gitpod_80}" ".configs/.env"


## Copying
docker cp ../bagisto $(cat apache_container_id):/var/www/html/
docker cp ../laravel-pwa $(cat apache_container_id):/var/www/html/

# installing composer dependencies inside container
docker exec -i $(cat apache_container_id) bash -c "cd bagisto && composer install"
docker exec -i $(cat apache_container_id) bash -c "cd bagisto && php artisan optimize:clear"
# docker exec -i $(cat apache_container_id) bash -c "cd bagisto && php artisan migrate:fresh --seed"
docker exec -i $(cat apache_container_id) bash -c "cd bagisto && php artisan storage:link"
docker exec -i $(cat apache_container_id) bash -c "cd bagisto && php artisan bagisto:publish --force"
docker exec -i $(cat apache_container_id) bash -c "cd bagisto && php artisan config:cache"
docker exec -i $(cat apache_container_id) bash -c "cd bagisto && php artisan migrate"
docker exec -i $(cat apache_container_id) bash -c "cd bagisto && php artisan route:cache"
docker exec -i $(cat apache_container_id) bash -c "cd bagisto && php artisan vendor:publish --all"
docker exec -i $(cat apache_container_id) bash -c "cd bagisto && php artisan optimize:clear"