package cursohadoop.citingpatents;

/*
 * Mapper para CitingPatents - cites by number: Obtiene el número de citas de una patente
 * Para cada línea, invierte las columnas (patente citada, patente que cita)
 */
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.io.Text;
import java.io.IOException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class CPMapper extends Mapper<Text, Text, Text, Text > {
	private final Text key_out = new Text();
	private final Text value_out = new Text();
	private final Pattern pat = Pattern.compile("\\b[0-9]+\\b");

	/*
	 * Método map
	 * @param key patente que cita
	 * @param value patente citada
	 * @param context Contexto MapReduce
	 * @see org.apache.hadoop.mapreduce.Mapper#map(KEYIN, VALUEIN, org.apache.hadoop.mapreduce.Mapper.Context)
	 */
	@Override
	public void map(Text key, Text value, Context ctxt) throws IOException, InterruptedException {
		// Saltamos la primera fila
		Matcher matcher = pat.matcher(key.toString());

		while (matcher.find()) {
			key_out.set(value.toString());
			value_out.set(key.toString());
			ctxt.write(key_out, value_out);
		}
	}
}
