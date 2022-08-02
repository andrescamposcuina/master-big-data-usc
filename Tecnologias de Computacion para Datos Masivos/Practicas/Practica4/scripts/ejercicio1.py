#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import print_function,division
from pyspark.sql import SparkSession
import pyspark.sql.functions as f
import sys

# Script para extraer información de los ficheros cite75_99.txt y apat63_99.txt. 
# a) A partir del fichero cite75_99.txt obtener el número de citas de cada patente. 
#    Debes obtener un DataFrame de la siguiente forma:
#   +--------+------+ 
#   |NPatente|ncitas|
#   +--------+------+
#   | 3060453|  3   |
#   | 3390168|  6   |
#   | 3626542| 18   | 
#   | 3611507|  5   |
#   | 3000113|  4   |
#
# b) A partir del fichero apat63_99.txt, crear un DataFrame que contenga el número de patente, 
# el país y el año, descartando el resto de campos del fichero.
# Ese DataFrame debe tener la siguiente forma:
#
#   +--------+----+----+ 
#   |NPatente|Pais|Anho|
#   +--------+----+----+
#   | 3070801| BE| 1963| 
#   | 3070802| US| 1963| 
#   | 3070803| US| 1963| 
#   | 3070804| US| 1963| 
#   | 3070805| US| 1963|
#
# Ejecutar en local con:
# spark-submit --master local[*] --driver-memory 4g ejercicio1.py path_a_cite75_99.txt path_a_apat63_99.txt dfCitas.parquet dfInfo.parquet
# Ejecución en un cluster YARN:
# spark-submit --master yarn --num-executors 8 --driver-memory 4g --queue urgent ejercicio1.py path_a_cite75_99.txt_en_HDFS path_a_apat63_99.txt_en_HDFS dfCitas.parquet dfInfo.parquet

def main():

    # Comprobamos que el número de argumentos es correcto
    if len(sys.argv) != 5:
        print("Usar: path_a_ejercicio1.py path_a_cite75_99.txt path_a_apat63_99.txt dfCitas.parquet dfInfo.parquet")
        exit(-1)
    
    # Apartado A
    input_file_a = sys.argv[1]
    output_path_a = sys.argv[3]
    
    # Apartado B
    input_file_b = sys.argv[2]
    output_path_b = sys.argv[4]

    spark = SparkSession.builder.appName("Ejercicio 1").getOrCreate()

    # Cambiamos la verbosidad para reducir el número de mensajes por pantalla
    spark.sparkContext.setLogLevel("FATAL")
    
    # Apartado A ---------------------------------------------------------------------------------------------------------------
    
    # En primer lugar, leemos el fichero .txt y almacenamos en un DataFrame
    dfCitas = spark.read.load(input_file_a, format='csv', sep=',', inferSchema='true', header='true')

    # Agrupamos por las patentes citadas
    dfCitasPorCited = dfCitas.groupBy('CITED').count()
    
    # Renombramos las columnas y ordenamos por el nº de la patente citada
    dfCitas = dfCitasPorCited.select(f.expr("CITED as NPatente"), f.expr("count as NCitas")).orderBy('NPatente', ascending = True)
    
    # Guardamos al fichero de salida usando Parquet, con compresión gzip
    dfCitas.write.format("parquet").mode("overwrite").option("compression", "gzip").save(output_path_a)
    
    # Imprimimos el número de particiones del DataFrame
    print("Número de particiones del dfCitas: {0}".format(dfCitas.rdd.getNumPartitions()))
    
    # Apartado B ---------------------------------------------------------------------------------------------------------------
    
    # En primer lugar, leemos el fichero .txt y almacenamos en un DataFrame
    dfInfo = spark.read.load(input_file_b, format='csv', sep=',', inferSchema='true', header='true', nullValue='null')
    
    # Descartamos los campos que no necesitamos
    dfInfo = dfInfo.select(f.expr("PATENT as NPatente"), f.expr("COUNTRY as Pais"), f.expr("GYEAR as Anho")).orderBy('NPatente', ascending = True)
    
    # Guardamos al fichero de salida usando Parquet, con compresión gzip
    dfInfo.write.format("parquet").mode("overwrite").option("compression", "gzip").save(output_path_b)
    
    # Imprimimos el número de particiones del DataFrame
    print("Número de particiones del dfInfo: {0}".format(dfInfo.rdd.getNumPartitions()))
    
    
if __name__ == "__main__":
    main()