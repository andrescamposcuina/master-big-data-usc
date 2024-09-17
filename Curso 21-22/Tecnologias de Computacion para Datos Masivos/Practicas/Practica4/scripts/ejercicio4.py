#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import print_function, division
from pyspark.sql import SparkSession
import pyspark.sql.functions as f
from pyspark.sql.window import Window
import sys

# Obtener a partir de los fichero Parquet creados en la practica 1 un DataFrame que proporcione, 
# para un grupo de países especificado, las patentes ordenadas por número de citas, de mayor a menor, 
# junto con una columna que indique el rango (posición de la patente en ese país/año según las citas obtenidas.
#
# La ejecución y salida del script debe ser como sigue:
# +----+----+--------+------+-----+
# |Pais|Anho|Npatente|Ncitas|Rango|
# +----+----+--------+------+-----+
# |ES  |1963|3093080 |20    |1    |
# |ES  |1963|3099309 |19    |2    |
# |ES  |1963|3081560 |9     |3    |
# |ES  |1963|3071439 |9     |3    |
# |ES  |1963|3074559 |6     |4    |
# |ES  |1963|3114233 |5     |5    |
# |ES  |1963|3094845 |4     |6    |
# |ES  |1963|3106762 |3     |7    |
# |ES  |1963|3088009 |3     |7    |
# |ES  |1963|3087842 |2     |8    |
# |ES  |1963|3078145 |2     |8    |
# |ES  |1963|3094806 |2     |8    |
# |ES  |1963|3073124 |2     |8    |
# |ES  |1963|3112201 |2     |8    |
# |ES  |1963|3102971 |1     |9    |
# |ES  |1963|3112703 |1     |9    |
# |ES  |1963|3095297 |1     |9    |
# |ES  |1964|3129307 |11    |1    |
# |ES  |1964|3133001 |10    |2    |
# |ES  |1964|3161239 |8     |3    |
# .................................
# |FR  |1963|3111006 |35    |1    |
# |FR  |1963|3083101 |22    |2    |
# |FR  |1963|3077496 |16    |3    |
# |FR  |1963|3072512 |15    |4    |
# |FR  |1963|3090203 |15    |4    |
# |FR  |1963|3086777 |14    |5    |
# |FR  |1963|3074344 |13    |6    |
# |FR  |1963|3096621 |13    |6    |
# |FR  |1963|3089153 |13    |6    |
#
# Ejecutar en local con:
# spark-submit --master local[*] --driver-memory 4g ejercicio4.py path_a_dfCitas.parquet_en_HDFS path_a_dfInfo.parquet_en_HDFS codigos_paises_separados_por_comas path_a_output_en_HDF
# Ejecución en un cluster YARN:
# spark-submit --master yarn --num-executors 8 --driver-memory 4g ejercicio4.py path_a_dfCitas.parquet_en_HDFS path_a_dfInfo.parquet_en_HDFS codigos_paises_separados_por_comas path_a_output_en_HDF

def main():

    # Comprobamos que el número de argumentos es correcto
    if len(sys.argv) != 5:
        print("Usar: path_a_ejercicio4.py_en_local path_a_dfCitas.parquet_en_HDFS path_a_dfInfo.parquet_en_HDFS codigos_paises_separados_por_comas path_a_output_en_HDF")
        exit(-1)
    
    # Almacenamos los paths a los ficheros
    dfCitas_path = sys.argv[1]
    dfInfo_path = sys.argv[2]
    country_list = sys.argv[3]
    output_path = sys.argv[4]

    spark = SparkSession.builder.appName("Ejercicio 4").getOrCreate()
    
    # Obtenemos el SparkContext
    sc = spark.sparkContext

    # Cambiamos la verbosidad para reducir el número de mensajes por pantalla
    sc.setLogLevel("FATAL")
    
    # En primer lugar, leemos los ficheros en formato Parquet y almacenamos en sus respectivos DataFrames
    dfCitas = spark.read.parquet(dfCitas_path)
    dfInfo = spark.read.parquet(dfInfo_path)
    
    # Renombramos la columna 'NPatente' en Info
    dfInfo = dfInfo.withColumnRenamed("NPatente", "NPatente_Info")
    
    # Hacemos el join de ambos DataFrames en uno solo:
    dfInner = dfCitas.join(dfInfo, dfCitas['NPatente'] == dfInfo['NPatente_Info'], 'inner').select('Pais', 'Anho', 'NPatente', 'NCitas')
    
    # Descartamos los paises que no hayan sido pasados como argumento
    dfEjercicio4 = dfInner.filter(f.col('Pais').isin(country_list.split(',')))
    
    # Obtenemos el rango mediante funciones de ventana
    window = Window.partitionBy(f.col('Pais'), f.col('Anho')).orderBy(f.col('NCitas').desc())
    colRango = f.dense_rank().over(window)
    
    # Renombramos las columnas y ordenamos
    dfEjercicio4 = dfEjercicio4.select(
        'Pais',
        'Anho',
        'NPatente',
        'NCitas',
        colRango.alias('Rango')
    ).orderBy(
        f.col('Pais').asc(), 
        f.col('Anho').asc(),
        f.col('NCitas').desc()
    )
    
    # Escribimos a un único fichero csv
    dfEjercicio4.coalesce(1).write.csv(output_path, mode='overwrite', header=True)
    
    
if __name__ == "__main__":
    main()