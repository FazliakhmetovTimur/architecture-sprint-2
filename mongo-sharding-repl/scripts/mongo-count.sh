#!/bin/bash

###
# Выводим количество документов
###

docker compose exec mongos_router mongosh --port 27020 --eval "db.helloDoc.countDocuments()" somedb;
docker compose exec shard1-r1 mongosh --port 27021 --eval "db.helloDoc.countDocuments()" somedb;
docker compose exec shard2-r1 mongosh --port 27031 --eval "db.helloDoc.countDocuments()" somedb;

# Выводим инфу по реликасетам
docker compose exec shard1-r1 mongosh --port 27021 --eval "db.adminCommand( { replSetGetStatus: 1 } )";
docker compose exec shard2-r1 mongosh --port 27031 --eval "db.adminCommand( { replSetGetStatus: 1 } )";