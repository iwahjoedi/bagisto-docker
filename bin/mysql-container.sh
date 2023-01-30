container_id=$(docker ps -aqf "name=trkomerce-mysql")

docker exec -it ${container_id} bash