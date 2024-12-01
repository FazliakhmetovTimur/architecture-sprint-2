#!/bin/bash

###
# Инициализируем бд
###

# инициализируем конфиг
docker compose exec -T configSrv mongosh --port 27017 --quiet <<EOF
rs.initiate(
  {
    _id : "config_server",
       configsvr: true,
    members: [
      { _id : 0, host : "configSrv:27017" }
    ]
  }
);
EOF

# инициализируем первый шард с его репликами
docker compose exec -T shard1-r1 mongosh --port 27021 --quiet <<EOF
rs.initiate(
    {
      _id : "shard1",
      members: [
        { _id : 0, host : "shard1-r1:27021" },
        { _id : 1, host : "shard1-r2:27022" },
        { _id : 2, host : "shard1-r3:27023" }
      ]
    }
);
EOF

# инициализируем второй шард с его репликами
docker compose exec -T shard2-r1 mongosh --port 27031 --quiet <<EOF
rs.initiate(
    {
      _id : "shard2",
      members: [
        { _id : 0, host : "shard2-r1:27031" },
        { _id : 1, host : "shard2-r2:27032" },
        { _id : 2, host : "shard2-r3:27033" }
      ]
    }
  );
EOF

# слип, чтобы реплики выбрали primary
echo "sleep 10 sec";
sleep 10;
echo "sleep finished";

# добавляем шарды с репликами в роутер
docker compose exec -T mongos_router mongosh --port 27020 --quiet <<EOF
sh.addShard( "shard1/shard1-r1:27021", "shard1/shard1-r2:27022", "shard1/shard1-r2:27023");
sh.addShard( "shard2/shard2-r1:27031", "shard2/shard2-r1:27031", "shard2/shard2-r1:27031");

sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )
EOF

# заполняем данные
docker compose exec -T mongos_router mongosh --port 27020 --quiet <<EOF
use somedb
for(var i = 0; i < 1000; i++) db.helloDoc.insertOne({age:i, name:"ly"+i});
EOF