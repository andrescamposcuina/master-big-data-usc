package cursohadoop.citingpatents;

/*
 * Reducer para CitingPatents - cites by number: Obtiene el número de citas de una patente
 * Para cada línea, obtiene la clave (patente) y une en un string el número de patentes que la citan
 */
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.io.Text;
import java.io.IOException;


public class CPReducer extends Reducer<Text, Text, Text, Text> {
	/*
	 * Método reduce
	 * @param key Patente citada
	 * @param values Lista con las patentes que la citan
	 * @param ctxt Contexto MapReduce
	 */
	@Override
	public void reduce(Text key, Iterable<Text> values, Context ctxt) throws IOException, InterruptedException {
		// Construimos la salida
		StringBuilder value_out = new StringBuilder();
		for (Text value : values){
			value_out.append(value.toString()).append(",");
		}

		// Eliminamos la coma del final
		value_out.setLength(value_out.length() - 1);

		// Escribimos al contexto
		ctxt.write(key, new Text(value_out.toString()));
	}

}


