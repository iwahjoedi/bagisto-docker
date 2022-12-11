# Bagisto Account
# account: 
# admin@admin@example.com:admin123

# container id by image name
apache_container_id=$(cat apache_container_id)

# update bagisto
# echo "Now, setting up Bagisto..."
# docker exec ${apache_container_id} git clone https://github.com/bagisto/bagisto
docker exec -i ${apache_container_id} bash -c "rm -rf bagisto"
docker cp ../bagisto ${apache_container_id}:/var/www/html/


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
# docker exec -i ${apache_container_id} bash -c "cd bagisto && php artisan config:cache"
# docker exec -i ${apache_container_id} bash -c "cd bagisto && php artisan migrate"
# docker exec -i ${apache_container_id} bash -c "cd bagisto && php artisan route:cache"
# docker exec -i ${apache_container_id} bash -c "cd bagisto && php artisan vendor:publish --all"