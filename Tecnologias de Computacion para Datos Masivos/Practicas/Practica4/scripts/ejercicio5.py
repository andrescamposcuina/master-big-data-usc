#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import print_function, division
from pyspark.sql import SparkSession
import pyspark.sql.functions as f
from pyspark.sql.window import Window
import sys

# Obtener a partir del fichero Parquet con la información de (Npatente, Pais y Año) un DataFrame que nos muestre 
# el número de patentes asociadas a cada país por cada década (entendemos por década los años del 0 al 9, 
# es decir de 1970 a 1979 es una década). Adicionalmente, debe mostrar el aumento o disminución del número de 
# patentes para cada país y década con respecto a la década anterior.
#
# El DataFrame generado tiene que ser como este:
# +----+------+---------+----+
# |Pais|Decada|NPatentes|Dif |
# +----+------+---------+----+
# |AD  |1980  |1        |0   |
# |AD  |1990  |5        |4   |
# |AE  |1980  |7        |0   |
# |AE  |1990  |11       |4   |
# |AG  |1970  |2        |0   |
# |AG  |1990  |7        |5   |
# |AI  |1990  |1        |0   |
# |AL  |1990  |1        |0   |
# |AM  |1990  |2        |0   |
# |AN  |1970  |1        |0   |
# |AN  |1980  |2        |1   |
# |AN  |1990  |5        |3   |
# |AR  |1960  |135      |0   |
# |AR  |1970  |239      |104 |
# |AR  |1980  |184      |-55 |
# |AR  |1990  |292      |108 |
#
# Ejecutar en local con:
# spark-submit --master local[*] --driver-memory 4g ejercicio5.py  path_a_dfInfo.parquet_en_HDFS path_a_output_en_HDF
# Ejecución en un cluster YARN:
# spark-submit --master yarn --num-executors 8 --driver-memory 4g --queue urgent ejercicio5.py  path_a_dfInfo.parquet_en_HDFS path_a_output_en_HDF

def main():

    # Comprobamos que el número de argumentos es correcto
    if len(sys.argv) != 3:
        print("Usar: path_a_ejercicio5.py_en_local path_a_dfInfo.parquet_en_HDFS path_a_output_en_HDF")
        exit(-1)
    
    # Almacenamos los paths a los ficheros
    dfInfo_path = sys.argv[1]
    output_path = sys.argv[2]

    spark = SparkSession.builder.appName("Ejercicio 5").getOrCreate()
    
    # Obtenemos el SparkContext
    sc = spark.sparkContext

    # Cambiamos la verbosidad para reducir el número de mensajes por pantalla
    sc.setLogLevel("FATAL")
    
    # En primer lugar, leemos los ficheros en formato Parquet y almacenamos en sus respectivos DataFrames
    dfInfo = spark.read.parquet(dfInfo_path)
    
    # Calculamos la decada de cada una de las filas
    dfInfoWithDecade = dfInfo.withColumn('Decada', f.col('Anho') - (f.col('Anho') % 10))
    
    # Agrupamos por decada
    dfInfoByDecade = dfInfoWithDecade.groupBy(f.col('Pais'), f.col('Decada')).count()
    
    # Calculamos la diferencia entre una decada y la anterior para cada país
    window = Window.partitionBy(f.col('Pais')).orderBy(f.col('Decada'))
    
    # Creamos una columna que referencia a la fila anterior por decada
    previousCol = f.lag(f.col('count'), 1).over(window)
    
    # Renombramos las columnas, calculamos la columna 'Dif' y ordenamos
    dfEjercicio5 = dfInfoByDecade.select(
        'Pais',
        'Decada',
        f.col('count').alias('NPatentes'),
        (f.col('count') - previousCol).alias("Dif")
    ).orderBy(
        f.col('Pais').asc(), 
        f.col('Decada').asc()
    ).fillna(0, subset=['Dif'])
    
    # Escribimos a un único fichero csv
    dfEjercicio5.coalesce(1).write.csv(output_path, mode='overwrite', header=True)
    
    
if __name__ == "__main__":
    main()