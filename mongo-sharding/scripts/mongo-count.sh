#!/bin/bash

###
# Выводим количество документов
###

docker compose exec mongos_router mongosh --port 27020 --eval "db.helloDoc.countDocuments()" somedb;

docker compose exec shard1 mongosh --port 27018 --eval "db.helloDoc.countDocuments()" somedb;

docker compose exec shard2 mongosh --port 27019 --eval "db.helloDoc.countDocuments()" somedb