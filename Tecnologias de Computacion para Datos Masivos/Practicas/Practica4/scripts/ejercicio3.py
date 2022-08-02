#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import print_function, division
from pyspark.sql import SparkSession
from operator import add
import sys

# Script que, a partir del fichero apat63_99.txt obtener el número de patentes por país y año usando RDDs (no uséis DataFrames).
# 1. El RDD obtenido debe ser un RDD clave/valor, en el cual la clave es un país y el valor una lista de tuplas, en la que cada tupla 
#    esté formada por un año y el número de patentes de ese país en ese año.
# 2. Adicionalmente, el RDD creado debe estar ordenado por el código del país y, para cada país, la lista de valores ordenados por año.
#
# Ejemplo de par clave/valor de salida:
# (u'PA', [(u'1963', 2), (u'1964', 2), (u'1965', 1), (u'1966', 1), (u'1970', 1), (u'1971', 1), (u'1972', 6), (u'1974', 3)])
#
# Ejecutar en local con:
# spark-submit --master local[*] --driver-memory 4g path_a_ejercicio3.py_en_local path_a_apat63_99.txt_en_HDFS path_a_ejercicio3_output_en_HDFS
# Ejecución en un cluster YARN:
# spark-submit --master yarn --num-executors 8 --driver-memory 4g --queue urgent path_a_ejercicio3.py_en_local path_a_apat63_99.txt_en_HDFS path_a_ejercicio3_output_en_HDFS

def main():

    # Comprobamos que el número de argumentos es correcto
    if len(sys.argv) != 3:
        print("Usar: path_a_ejercicio3.py_en_local path_a_apat63_99.txt_en_HDFS path_a_ejercicio3_output_en_HDFS")
        # exit(-1)
        
    # Almacenamos los paths a los ficheros
    apat63_99_path = sys.argv[1]
    output_path = sys.argv[2]

    spark = SparkSession.builder.appName("Ejercicio 3").getOrCreate()
    
    # Obtenemos el SparkContext
    sc = spark.sparkContext

    # Cambiamos la verbosidad para reducir el número de mensajes por pantalla
    sc.setLogLevel("FATAL")
    
    # Cargamos el fichero a un RDD usando 8 particiones
    apat63_99_rdd = sc.textFile(apat63_99_path, 8)
    
    # Eliminamos la cabecera ya que no nos hace falta
    apat63_99_rdd = apat63_99_rdd.zipWithIndex().filter(lambda x: x[1] > 0).map(lambda x: x[0])
    
    # Eliminamos las comillas dobles del código del país
    apat63_99_rdd = apat63_99_rdd.map(lambda x: x.replace('\"', ""))
    
    # Eliminamos los campos que no nos hacen falta
    apat63_99_rdd = apat63_99_rdd.map(lambda x: (x.split(",")[4], x.split(',')[1]))
    
    # 1. Ponemos la tupla (COUNTRY, GYEAR) como clave, 1 como valor, reducimos por la clave y ordenamos
    apat63_99_rdd = apat63_99_rdd.map(lambda x: ((x[0], x[1]), 1) ).reduceByKey(add).sortByKey()
    
    # 2. Ajustamos la clave a COUNTRY, el valor a [(GYEAR, count)], reducimos por COUNTRY concatenando las listas y ordenamos por COUNTRY
    apat63_99_rdd = apat63_99_rdd.map(lambda x: (x[0][0], [(x[0][1], x[1])])).reduceByKey(add).sortByKey()
    
    # Finalmente escribimos la salida en formato de texto sin comprimir
    apat63_99_rdd.saveAsTextFile(output_path)
    
    
if __name__ == "__main__":
    main()