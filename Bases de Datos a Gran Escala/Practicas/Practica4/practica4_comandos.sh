# Iniciar los servidores de configuración:
mkdir servconf
nohup mongod --configsvr --replSet rsConfServer --port 27017 --dbpath /home/alumnogreibd/servconf --bind_ip localhost,192.168.56.xxx > /dev/null &

# Nos conectamos, en el cluster1, a Mongo:
mongo --host localhost --port 27017

# Iniciamos el replicaSet rsConfServer
rs.initiate({
  _id: "rsConfServer",
  configsvr: true,
  members: [
      {_id: 0, host: "192.168.56.105:27017"},
      {_id: 1, host: "192.168.56.106:27017"},
      {_id: 2, host: "192.168.56.107:27017"}
      ]
})

# rsShard1

# Iniciamos los procesos mongod shardsvr
mkdir shard1
nohup mongod --shardsvr --replSet rsShard1 --port 27018 --dbpath /home/alumnogreibd/shard1 --bind_ip localhost,192.168.56.xxx > /dev/null &

# Nos conectamos en el cluster1
mongo --host localhost --port 27018

# Iniciamos el replicaSet rsShard1
rs.initiate({
  _id: "rsShard1",
  members: [
      {_id: 0, host: "192.168.56.105:27018"},
      {_id: 1, host: "192.168.56.106:27018"},
      {_id: 2, host: "192.168.56.107:27018"}
      ]
})

# rsShard2

# Iniciamos los procesos mongod shardsvr
mkdir shard2
nohup mongod --shardsvr --replSet rsShard2 --port 27019 --dbpath /home/alumnogreibd/shard2 --bind_ip localhost,192.168.56.xxx > /dev/null &

# Nos conectamos en el cluster1
mongo --host localhost --port 27019

# Iniciamos el replicaSet rsShard2
rs.initiate({
  _id: "rsShard2",
  members: [
      {_id: 0, host: "192.168.56.105:27019"},
      {_id: 1, host: "192.168.56.106:27019"},
      {_id: 2, host: "192.168.56.107:27019"}
      ]
})

# rsShard3

# Iniciamos los procesos mongod shardsvr
mkdir shard3
nohup mongod --shardsvr --replSet rsShard3 --port 27020 --dbpath /home/alumnogreibd/shard3 --bind_ip localhost,192.168.56.xxx > /dev/null &

# Nos conectamos en el cluster1
mongo --host localhost --port 27020

# Iniciamos el replicaSet rsShard3
rs.initiate({
  _id: "rsShard3",
  members: [
      {_id: 0, host: "192.168.56.105:27020"},
      {_id: 1, host: "192.168.56.106:27020"},
      {_id: 2, host: "192.168.56.107:27020"}
      ]
})

# Iniciamos el proceso mongos que actúe como punto de entrada al cluster
nohup mongos --port 27021 --configdb rsConfServer/192.168.56.105:27017,192.168.56.106:27017,192.168.56.107:27017 --bind_ip localhost,192.168.56.xxx > /dev/null &

# Nos conectamos en cluster1
mongo --host localhost --port 27021

# Añadimos los shards
sh.addShard("rsShard1/192.168.56.105:27018,192.168.56.106:27018,192.168.56.107:27018")
sh.addShard("rsShard2/192.168.56.105:27019,192.168.56.106:27019,192.168.56.107:27019")
sh.addShard("rsShard3/192.168.56.105:27020,192.168.56.106:27020,192.168.56.107:27020")

# Habilitamos el sharding en una base de datos de prueba
use bdge
sh.enableSharding("bdge")

# Copiamos las películas 
mongoimport --host=localhost:27021 --db=bdge --collection peliculas --file=/home/alumnogreibd/data/peliculas.json

# Indexamos y particionamos 
db.peliculas.createIndex({id:"hashed"})
sh.shardCollection("bdge.peliculas", {id:"hashed"})

# Consulta número 1:
db.peliculas.find(
  {
    presupuesto:{$gt:500000}
    }
).count()

# Arrancar todos los procesos
# cluster1
nohup mongod --configsvr --replSet rsConfServer --port 27017 --dbpath /home/alumnogreibd/servconf --bind_ip localhost,192.168.56.105 > /dev/null 2>&1 &
nohup mongod --shardsvr --replSet rsShard1 --port 27018 --dbpath /home/alumnogreibd/shard1 --bind_ip localhost,192.168.56.105 > /dev/null &
nohup mongod --shardsvr --replSet rsShard2 --port 27019 --dbpath /home/alumnogreibd/shard2 --bind_ip localhost,192.168.56.105 > /dev/null &
nohup mongod --shardsvr --replSet rsShard3 --port 27020 --dbpath /home/alumnogreibd/shard3 --bind_ip localhost,192.168.56.105 > /dev/null &
nohup mongos --port 27021 --configdb rsConfServer/192.168.56.105:27017,192.168.56.106:27017,192.168.56.107:27017 --bind_ip localhost,192.168.56.105 > /dev/null &

# cluster2
nohup mongod --configsvr --replSet rsConfServer --port 27017 --dbpath /home/alumnogreibd/servconf --bind_ip localhost,192.168.56.106 > /dev/null 2>&1 &
nohup mongod --shardsvr --replSet rsShard1 --port 27018 --dbpath /home/alumnogreibd/shard1 --bind_ip localhost,192.168.56.106 > /dev/null &
nohup mongod --shardsvr --replSet rsShard2 --port 27019 --dbpath /home/alumnogreibd/shard2 --bind_ip localhost,192.168.56.106 > /dev/null &
nohup mongod --shardsvr --replSet rsShard3 --port 27020 --dbpath /home/alumnogreibd/shard3 --bind_ip localhost,192.168.56.106 > /dev/null &
nohup mongos --port 27021 --configdb rsConfServer/192.168.56.105:27017,192.168.56.106:27017,192.168.56.107:27017 --bind_ip localhost,192.168.56.106 > /dev/null 2>&1 &

# cluster3
nohup mongod --configsvr --replSet rsConfServer --port 27017 --dbpath /home/alumnogreibd/servconf --bind_ip localhost,192.168.56.107 > /dev/null 2>&1 &
nohup mongod --shardsvr --replSet rsShard1 --port 27018 --dbpath /home/alumnogreibd/shard1 --bind_ip localhost,192.168.56.107 > /dev/null &
nohup mongod --shardsvr --replSet rsShard2 --port 27019 --dbpath /home/alumnogreibd/shard2 --bind_ip localhost,192.168.56.107 > /dev/null &
nohup mongod --shardsvr --replSet rsShard3 --port 27020 --dbpath /home/alumnogreibd/shard3 --bind_ip localhost,192.168.56.107 > /dev/null &
nohup mongos --port 27021 --configdb rsConfServer/192.168.56.105:27017,192.168.56.106:27017,192.168.56.107:27017 --bind_ip localhost,192.168.56.107 > /dev/null &

# Ejercicio 11:
db.peliculas.updateMany(
  {},
  [
    { 
    "$set": {
      "fecha_emision": { 
        "$dateFromString": {
          dateString: "$fecha_emision"
          } 
        }
      }
    }
  ]
);

# Ejercicio 12:
db.peliculas.find(
  {
    "generos.nombre": "Science Fiction",
    ingresos:{$gt:800000000}
  },
  {
    titulo:1,
    presupuesto:1,
    _id:0
  }
).pretty()

# Ejercicio 13:
db.peliculas.aggregate(
  [
    {
      $match: {
        "reparto.persona.nombre": "Penélope Cruz",
        "generos.nombre": "Action"
      }
    },
    {
      $project: {
        titulo:1,
        titulo_original:1,
        _id:0
      }
    },
    {$sort: {fecha_emision:-1}}
  ]
)

# Ejercicio 14:
db.peliculas.aggregate([
  { $unwind: '$generos' }, 
  {
    $replaceRoot: {
        newRoot: {
            $mergeObjects: [
              { ingresos: '$ingresos' },
              { presupuesto: '$presupuesto' },
              "$generos"
            ]
        }
    }
  },
  {
    $group: {
        _id: '$nombre',
        peliculas: { $sum: 1 },
        ingresos_totales: { $sum: '$ingresos' },
        presupuesto_total: { $sum: '$presupuesto' }
    }
  },
  {
    "$project" : {
      _id:0,
      'genero': '$_id',
      'peliculas': '$peliculas',
      'ingresos_totales' : '$ingresos_totales',
      'presupuesto_total' : '$presupuesto_total',
      'beneficios':{'$subtract':['$ingresos_totales', '$presupuesto_total']},
    }
  },
  { $sort: {beneficios:-1} }
])

# Ejercicio 15:
db.peliculas.aggregate([
  { $unwind: '$personal' }, 
  {
    $replaceRoot: {
        newRoot: {
            $mergeObjects: [
              { ingresos: '$ingresos' },
              { duracion: '$duracion' },
              "$personal"
            ]
        }
    }
  },
  {
    $match: {
        trabajo: "Director",
        ingresos:{$gt:0}
    }
  },
  {
    $group: {
        _id: '$persona.nombre',
        peliculas: { $sum: 1 },
        ingresos_totales: { $sum: '$ingresos' },
        duracion_media: { $avg: '$duracion' }
    }
  },
  {
    "$project" : {
      _id:0,
      'director': '$_id',
      'peliculas': '$peliculas',
      'ingresos_totales' : '$ingresos_totales',
      'duracion_media' : '$duracion_media'
    }
  },
  { $sort: {duracion_media:-1} },
  { $limit: 10 }
])