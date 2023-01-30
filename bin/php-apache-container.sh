container_id=$(docker ps -aqf "name=trkomerce-php-apache")

docker exec -it ${container_id} bash