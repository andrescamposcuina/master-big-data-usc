#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import print_function, division
from pyspark.sql import SparkSession
import pyspark.sql.functions as f
import sys

# Script que, a partir de los datos en Parquet de la práctica anterior, obtenga para cada país y para cada año el total de patentes, 
# el total de citas obtenidas por todas las patentes, la media de citas y el máximo número de citas.
# Obtener solo aquellos casos en los que existan valores en ambos ficheros (inner join).
# Cada país tiene que aparecer con su nombre completo, obtenido del fichero country_codes.txt, residente en el disco local.
# El DataFrame generado debe estar ordenado por país y, para cada país, por año
# Ejemplo de salida:
# +-------------------+----+-----------+----------+------------------+--------+
# |Pais               |Anho|NumPatentes|TotalCitas|MediaCitas        |MaxCitas|
# +-------------------+----+-----------+----------+------------------+--------+
# |Algeria            |1963|2          |7         |3.5               |4       |
# |Algeria            |1968|1          |2         |2.0               |2       |
# |Algeria            |1970|1          |2         |2.0               |2       |
# |Algeria            |1972|1          |1         |1.0               |1       |
# |Algeria            |1977|1          |2         |2.0               |2       |
# |Andorra            |1987|1          |3         |3.0               |3       |
# |Andorra            |1993|1          |1         |1.0               |1       |
# |Andorra            |1998|1          |1         |1.0               |1       |
# |Antigua and Barbuda|1978|1          |6         |6.0               |6       |
# |Antigua and Barbuda|1979|1          |14        |14.0              |14      |
# |Antigua and Barbuda|1991|1          |8         |8.0               |8       |
# |Antigua and Barbuda|1994|1          |19        |19.0              |19      |
# |Antigua and Barbuda|1995|2          |12        |6.0               |11      |
# |Antigua and Barbuda|1996|2          |3         |1.5               |2       |
# |Argentina          |1963|14         |35        |2.5               |7       |
# |Argentina          |1964|20         |60        |3.0               |8       |
# |Argentina          |1965|10         |35        |3.5               |10      |
# |Argentina          |1966|16         |44        |2.75              |9       |
# |Argentina          |1967|13         |60        |4.615384615384615 |14      |
#
# Ejecutar en local con:
# spark-submit --master local[*] --driver-memory 4g ejercicio2.py path_a_dfCitas.parquet_en_HDFS path_a_dfInfo.parquet_en_HDFS path_a_country_codes.txt_en_local path_a_output_en_HDF
# Ejecución en un cluster YARN:
# spark-submit --master yarn --num-executors 8 --driver-memory 4g --queue urgent ejercicio2.py path_a_dfCitas.parquet_en_HDFS path_a_dfInfo.parquet_en_HDFS path_a_country_codes.txt_en_local path_a_output_en_HDF
    

def main():
    # Comprobamos que el número de argumentos es correcto
    if len(sys.argv) != 5:
        print("Usar: path_a_ejercicio2.py_en_local path_a_dfCitas.parquet_en_HDFS path_a_dfInfo.parquet_en_HDFS path_a_country_codes.txt_en_local path_a_output_en_HDFS")
        exit(-1)
    
    # Almacenamos los paths a los ficheros
    dfCitas_path = sys.argv[1]
    dfInfo_path = sys.argv[2]
    country_codes_path = sys.argv[3]
    output_path = sys.argv[4]

    spark = SparkSession.builder.appName("Ejercicio 2").getOrCreate()
    
    # Obtenemos el SparkContext
    sc = spark.sparkContext

    # Cambiamos la verbosidad para reducir el número de mensajes por pantalla
    sc.setLogLevel("FATAL")
    
    # Enviamos el contenido del fichero country_codes.txt como variable de broadcast
    country_codes_dict = { line.split()[0] : line.split()[1].rstrip('\n') for line in open(country_codes_path) }
    bcast_country_codes = sc.broadcast(country_codes_dict)
    
    # En primer lugar, leemos los ficheros en formato Parquet y almacenamos en sus respectivos DataFrames
    dfCitas = spark.read.parquet(dfCitas_path)
    dfInfo = spark.read.parquet(dfInfo_path)
    
    # Renombramos la columna 'NPatente' en Info
    dfInfo = dfInfo.withColumnRenamed("NPatente", "NPatente_Info")
    
    # Hacemos el join de ambos DataFrames en uno solo:
    dfInner = dfCitas.join(dfInfo, dfCitas['NPatente'] == dfInfo['NPatente_Info'], 'inner').select('NPatente', 'NCitas', 'Pais', 'Anho')
    
    # Obtenemos el nombre completo del país a partir de su código
    dfInner = dfInner.rdd.map(lambda x: (x[0], x[1], bcast_country_codes.value.get(x[2]), x[3])).toDF(['NPatente', 'NCitas', 'Pais', 'Anho'])
    
    # Calculamos los agregados
    dfEjercicio2_aggregated = dfInner.groupBy(f.col('Pais'), f.col('Anho')).agg(f.count('NPatente'), f.sum('NCitas'), f.avg('NCitas'), f.max('NCitas'))
    
    # Renombramos las columnas y ordenamos
    dfEjercicio2 = dfEjercicio2_aggregated.select(
        'Pais',
        'Anho',
        f.col('count(NPatente)').alias('NumPatentes'),
        f.col('sum(NCitas)').alias('TotalCitas'),
        f.col('avg(NCitas)').alias('MediaCitas'),
        f.col('max(NCitas)').alias('MaxCitas')
    ).orderBy(
        f.col('Pais').asc(), 
        f.col('Anho').asc()
    )
    
    # Escribimos a un único fichero csv
    dfEjercicio2.coalesce(1).write.csv(output_path, mode='overwrite', header=True)
    
if __name__ == "__main__":
    main()