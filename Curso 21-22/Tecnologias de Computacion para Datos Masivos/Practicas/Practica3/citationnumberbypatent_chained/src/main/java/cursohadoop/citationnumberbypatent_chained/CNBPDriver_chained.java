package cursohadoop.citationnumberbypatent_chained;

/*
 *  CNBP_a - cites number by patent: Obtiene el número de citas de una patente 
 *  Combina mapper | reducer | mapper
 *     
 *  mapper1 -> CPMapper (práctica 01-citingpatents)
 *             Para cada línea, invierte las columnas (patente citada, patente que cita)
 *  reducer -> CPReducer(práctica 01-citingpatents)
 *     		   Para cada línea, obtiene la clave (patente) y une en un string las patentes que la citan
 *  mapper2 -> CCMapper
 *     		   De la salida del reducer, para cada patente cuenta el número de patentes que la citan
 *      
 */

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.input.KeyValueTextInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.mapreduce.lib.output.TextOutputFormat;
import org.apache.hadoop.util.ToolRunner;
import org.apache.hadoop.mapreduce.lib.chain.ChainMapper;
import org.apache.hadoop.mapreduce.lib.chain.ChainReducer;

import cursohadoop.citingpatents.CPMapper;
import cursohadoop.citingpatents.CPReducer;

public class CNBPDriver_chained extends Configured implements Tool {
	@Override
	public int run(String[] args) throws Exception {

		/*
		 * Comprueba los parámetros de entrada  
		 */
		if (args.length != 2) {
			System.err.printf("Usar: %s [opciones genéricas] <directorio_entrada> <directorio_salida>%n", getClass().getSimpleName());
			System.err.print("Recuerda que el directorio de salida no puede existir");
			ToolRunner.printGenericCommandUsage(System.err);
			return -1;
		}

		// Obtenemos la configuración por defecto y modifica el separador clave valor
		Configuration conf = getConf();

		// Modificamos el parámetro para indicar que el caracter separador entre clave y
		// valor en el fichero de entrada es una coma
		conf.set("mapreduce.input.keyvaluelinerecordreader.key.value.separator", ",");

		// Modificamos el parámetro para indicar que el caracter separador entre clave y
		// valor en el fichero de salida es un tabulador
		conf.set("mapred.textoutputformat.separator", ",");
		
		// Definimos el job
		Job job = Job.getInstance(conf);
		job.setJobName("CitationNumberByPatentChained");

		// Fijamos el jar del trabajo a partir de la clase del objeto actual
		job.setJarByClass(getClass());

		// Añadimos al job los paths de entrada y salida
		FileInputFormat.addInputPath(job, new Path(args[0]));
		FileOutputFormat.setOutputPath(job, new Path(args[1]));

		// Fijamos el formato de los ficheros de entrada y salida
		job.setInputFormatClass(KeyValueTextInputFormat.class);
		job.setOutputFormatClass(TextOutputFormat.class);

		// Número de reducers
		job.setNumReduceTasks(4);

		// Especificamos el primer mapper
		// El booleano (true) especifica si los datos en la cadena se pasan por valor (true) o referencia (false)
		ChainMapper.addMapper(job, CPMapper.class, Text.class, Text.class, Text.class, Text.class, new Configuration(false));
		
		// Añadimos el reducer
		ChainReducer.setReducer(job,CPReducer.class, Text.class, Text.class, Text.class, Text.class, new Configuration(false));
		
		// Concatenamos los siguientes mapper al reducer
		ChainReducer.addMapper(job, CCMapper.class, Text.class, Text.class, Text.class, IntWritable.class, new Configuration(false));

		return job.waitForCompletion(true) ? 0 : 1;
	}

	/*
	 * Usar yarn jar CitationNumberByPatent_chained.jar dir_entrada dir_salida
	 * 
	 * @param args dir_entrada dir_salida
	 */
	public static void main(String[] args) throws Exception {
		int exitCode = ToolRunner.run(new Configuration(), new CNBPDriver_chained(), args);
		System.exit(exitCode);
	}

}

