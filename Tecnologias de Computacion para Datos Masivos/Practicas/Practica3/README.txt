Se entregan 4 carpetas que contienen cada una de ellas el código de cada uno de los ejercicios de esta entrega.
Estas carpetas son:
	- Ejercicio1: citingpatents
	- Ejercicio2: citationnumberbypatent_chained
	- Ejercicio3: creasequencefile
	- Ejercicio4: avgclaimsbypatent

En cada una de estas carpetas se encuentra el código para resolver el ejercicio correspondiente. Además, también se incluye el directorio output en el que están las salidad de la ejecución de cada uno de los ejercicios.
Para compilar y ejecutar cada uno de los siguientes ejercicios se hace de la siguiente manera:

- Ejercicio 1:

Para compilar, dentro del directorio citingpatents/, ejecutar los siguientes comandos:
module load maven
mvn package

Para ejecutar, dentro del directorio citingpatents/, usar el siguiente comando:
yarn jar target/citingpatents-0.0.1-SNAPSHOT.jar -Dmapred.job.queue.name=urgent path_a_cite75_99.txt_en_HDFS dir_salida_en_HDFS 

- Ejercicio 2:

Para compilar, dentro del directorio citationnumberbypatent_chained/, ejecutar los siguientes comandos:
module load maven
mvn package

Para ejecutar, dentro del directorio citationnumberbypatent_chained/, ejecutar los siguientes comandos:
export HADOOP_CLASSPATH="./src/resources/citingpatents-0.0.1-SNAPSHOT.jar"
yarn jar target/citationnumberbypatent_chained-0.0.1-SNAPSHOT.jar -Dmapred.job.queue.name=urgent -libjars $HADOOP_CLASSPATH path_a_cite75_99.txt_en_HDFS dir_salida_en_HDFS 

- Ejercicio 3:

Para compilar, dentro del directorio creasequencefile/, ejecutar los siguientes comandos:
module load maven
mvn package

Para ejecutar, dentro del directorio creasequencefile/, usar el siguiente comando:
yarn jar target/creasequencefile-0.0.1-SNAPSHOT.jar -Dmapred.job.queue.name=urgent -files path_a_country_codes.txt_en_local path_a_apat63_99.txt_en_HDFS dir_salida_en_HDFS

- Ejercicio 4:

Para poder ejecutar correctamente, estando dentro del directorio avgclaimsbypatent/, es necesario ejecutar los siguientes comandos:
sed -i -e 's/\r$//' ./*.py
chmod 700 *.py

Estos comandos le dan permisos de ejecución a los fichero .py y además cambian los finales de línea del formato DOS al formato UNIX (esto último sólo es necesario si los ficheros .py se editaron en Windows)

Para ejecutar, dentro del directorio avgclaimsbypatent/, usar el siguiente comando:
yarn jar /opt/cloudera/parcels/CDH-6.1.1-1.cdh6.1.1.p0.875250/lib/hadoop-mapreduce/hadoop-streaming.jar -D mapreduce.job.reduces=2 -Dmapred.job.queue.name=urgent -files CBPMapper.py,CBPReducer.py -input path_a_apat63_99.txt_en_HDFS -output dir_salida_en_HDFS -mapper CBPMapper.py -reducer CBPReducer.py

