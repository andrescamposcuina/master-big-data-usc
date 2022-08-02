package gal.usc.etse.mbd.bdge.hbasetest;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.NavigableMap;
import java.util.Set;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.hbase.HBaseConfiguration;
import org.apache.hadoop.hbase.TableName;
import org.apache.hadoop.hbase.client.Connection;
import org.apache.hadoop.hbase.client.ConnectionFactory;
import org.apache.hadoop.hbase.client.Put;
import org.apache.hadoop.hbase.client.Result;
import org.apache.hadoop.hbase.client.ResultScanner;
import org.apache.hadoop.hbase.client.Scan;
import org.apache.hadoop.hbase.client.Table;
import org.apache.hadoop.hbase.filter.SingleColumnValueFilter;
import org.apache.hadoop.hbase.CompareOperator;
import org.apache.hadoop.hbase.filter.FilterList;
import org.apache.hadoop.hbase.util.Bytes;

/**
 * @author alumnogreibd
 */
public class DAOPeliculasHBase implements DAOPeliculas {
    Connection con;

    public DAOPeliculasHBase() {
        try {
            Configuration conf = HBaseConfiguration.create();
            this.con = ConnectionFactory.createConnection(conf);
        } catch (IOException ex) {
            System.out.print("Error conectando con HBase: " + ex.getMessage() + "\n");
        }
    }

    @Override
    public void close() {
        try {
            con.close();
        } catch (IOException ex) {
            System.out.print("Error cerrando conexión con HBase: " + ex.getMessage() + "\n");
        }
    }

    @Override
    public List<Pelicula> getPeliculas(int num) {
        List<Pelicula> resultado = new ArrayList<>();

        try {
            Scan scan = new Scan();
            scan.addFamily(Bytes.toBytes("info"));
            scan.addFamily(Bytes.toBytes("reparto"));
            scan.addFamily(Bytes.toBytes("personal"));
            scan.setLimit(num);
            Table pelsTable = con.getTable(TableName.valueOf("peliculas"));

            try (ResultScanner rs = pelsTable.getScanner(scan)) {
                for (Result filaPelicula = rs.next(); filaPelicula != null; filaPelicula = rs.next()) {
                    NavigableMap mapReparto = filaPelicula.getFamilyMap(Bytes.toBytes("reparto"));
                    Reparto[] reparto = new Reparto[mapReparto.size()];

                    int i = 0;
                    for (Map.Entry<byte[], byte[]> elemReparto : (Set<Map.Entry>) mapReparto.entrySet()) {
                        reparto[i] = (Reparto) Utils.deserialize(elemReparto.getValue());
                        i++;
                    }

                    NavigableMap mapPersonal = filaPelicula.getFamilyMap(Bytes.toBytes("personal"));
                    Personal[] personal = new Personal[mapPersonal.size()];

                    i = 0;
                    for (Map.Entry<byte[], byte[]> elemPersonal : (Set<Map.Entry>) mapPersonal.entrySet()) {
                        personal[i] = (Personal) Utils.deserialize(elemPersonal.getValue());
                        i++;
                    }

                    NavigableMap mapInfo = filaPelicula.getFamilyMap(Bytes.toBytes("info"));
                    resultado.add(
                            new Pelicula(
                                    Bytes.toInt((byte[]) mapInfo.get(Bytes.toBytes("id"))),
                                    Bytes.toString((byte[]) mapInfo.get(Bytes.toBytes("titulo"))),
                                    new Date(Bytes.toLong((byte[]) mapInfo.get(Bytes.toBytes("fechaEmision")))),
                                    Bytes.toLong((byte[]) mapInfo.get(Bytes.toBytes("presupuesto"))),
                                    Bytes.toLong((byte[]) mapInfo.get(Bytes.toBytes("ingresos"))),
                                    reparto,
                                    personal
                            )
                    );
                }
            }
        } catch (IOException | ClassNotFoundException ex) {
            System.out.print("Error al consultar la tabla de películas en HBase: " + ex.getMessage() + "\n");
        }
        return resultado;
    }

    @Override
    public void insertaPelicula(Pelicula p) {
        try {
            Put put = new Put(Bytes.toBytes(p.getIdPelicula()));
            put.addColumn(Bytes.toBytes("info"), Bytes.toBytes("id"), Bytes.toBytes(p.getIdPelicula()));
            put.addColumn(Bytes.toBytes("info"), Bytes.toBytes("titulo"), Bytes.toBytes(p.getTitulo()));
            put.addColumn(Bytes.toBytes("info"), Bytes.toBytes("fechaEmision"), Bytes.toBytes(p.getFechaEmsion().getTime()));
            put.addColumn(Bytes.toBytes("info"), Bytes.toBytes("presupuesto"), Bytes.toBytes(p.getPresupuesto()));
            put.addColumn(Bytes.toBytes("info"), Bytes.toBytes("ingresos"), Bytes.toBytes(p.getIngresos()));

            for (int i = 0; i < p.getTamanoReparto(); i++) {
                put.addColumn(
                        Bytes.toBytes("reparto"),
                        Bytes.toBytes(String.format("r%04d", p.getReparto(i).getOrden())),
                        Utils.serialize(p.getReparto(i))
                );
            }

            for (int i = 0; i < p.getTamanoPersonal(); i++) {
                put.addColumn(
                        Bytes.toBytes("personal"),
                        Bytes.toBytes(String.format("p%04d", i)),
                        Utils.serialize(p.getPersonal(i))
                );
            }

            Table pelsTable = con.getTable(TableName.valueOf("peliculas"));
            pelsTable.put(put);
        } catch (IOException ex) {
            System.out.print("Error al insertar la pelicula: " + ex.getMessage() + "\n");
        }
    }

    @Override
    public Pelicula getPelicula(int id) {
        Pelicula resultado = null;

        try {
            Scan scan = new Scan();
            
            scan.addFamily(Bytes.toBytes("info"));
            scan.addFamily(Bytes.toBytes("reparto"));
            scan.addFamily(Bytes.toBytes("personal"));
            
            // Añadimos el filtro
            SingleColumnValueFilter filter = new SingleColumnValueFilter(
                    Bytes.toBytes("info"),
                    Bytes.toBytes("id"),
                    CompareOperator.EQUAL,
                    Bytes.toBytes(id)
            );
            scan.setFilter(filter);  
            
            // Obtenemos la tabla en la que ejecutar la busqueda
            Table pelsTable = con.getTable(TableName.valueOf("peliculas"));

            try (ResultScanner rs = pelsTable.getScanner(scan)) {
                for (Result filaPelicula = rs.next(); filaPelicula != null; filaPelicula = rs.next()) {
                    NavigableMap mapReparto = filaPelicula.getFamilyMap(Bytes.toBytes("reparto"));
                    Reparto[] reparto = new Reparto[mapReparto.size()];

                    int i = 0;
                    for (Map.Entry<byte[], byte[]> elemReparto : (Set<Map.Entry>) mapReparto.entrySet()) {
                        reparto[i] = (Reparto) Utils.deserialize(elemReparto.getValue());
                        i++;
                    }

                    NavigableMap mapPersonal = filaPelicula.getFamilyMap(Bytes.toBytes("personal"));
                    Personal[] personal = new Personal[mapPersonal.size()];

                    i = 0;
                    for (Map.Entry<byte[], byte[]> elemPersonal : (Set<Map.Entry>) mapPersonal.entrySet()) {
                        personal[i] = (Personal) Utils.deserialize(elemPersonal.getValue());
                        i++;
                    }

                    NavigableMap mapInfo = filaPelicula.getFamilyMap(Bytes.toBytes("info"));
                    resultado = new Pelicula(
                            Bytes.toInt((byte[]) mapInfo.get(Bytes.toBytes("id"))),
                            Bytes.toString((byte[]) mapInfo.get(Bytes.toBytes("titulo"))),
                            new Date(Bytes.toLong((byte[]) mapInfo.get(Bytes.toBytes("fechaEmision")))),
                            Bytes.toLong((byte[]) mapInfo.get(Bytes.toBytes("presupuesto"))),
                            Bytes.toLong((byte[]) mapInfo.get(Bytes.toBytes("ingresos"))),
                            reparto,
                            personal
                    );
                }
            }
        } catch (IOException | ClassNotFoundException ex) {
            System.out.print("Error al consultar la tabla de películas en HBase: " + ex.getMessage() + "\n");
        }
        return resultado;
    }

    @Override
    public List<Reparto> getRepartoPorNombre(String nombre) {
        List<Reparto> reparto = new ArrayList<>();

        try {
            Scan scan = new Scan();
            
            scan.addFamily(Bytes.toBytes("info"));
            scan.addFamily(Bytes.toBytes("reparto"));
            
            // Añadimos el filtro
            SingleColumnValueFilter filter = new SingleColumnValueFilter(
                    Bytes.toBytes("info"),
                    Bytes.toBytes("titulo"),
                    CompareOperator.EQUAL,
                    Bytes.toBytes(nombre)
            );
            scan.setFilter(filter);
            
            // Obtenemos la tabla en la que ejecutar la busqueda
            Table pelsTable = con.getTable(TableName.valueOf("peliculas"));

            try (ResultScanner rs = pelsTable.getScanner(scan)) {
                for (Result filaPelicula = rs.next(); filaPelicula != null; filaPelicula = rs.next()) {
                    NavigableMap mapReparto = filaPelicula.getFamilyMap(Bytes.toBytes("reparto"));

                    for (Map.Entry<byte[], byte[]> elemReparto : (Set<Map.Entry>) mapReparto.entrySet()) {
                        reparto.add((Reparto) Utils.deserialize(elemReparto.getValue()));
                    }
                }
            }
        } catch (IOException | ClassNotFoundException ex) {
            System.out.print("Error al consultar la tabla de películas en HBase: " + ex.getMessage() + "\n");
        }
        return reparto;
    }

    @Override
    public List<Pelicula> getInfoPorPresupuesto(long presupuesto) {
        List<Pelicula> resultado = new ArrayList<>();

        try {
            Scan scan = new Scan();
            scan.addFamily(Bytes.toBytes("info"));
            
            // Añadimos el filtro
            SingleColumnValueFilter filter = new SingleColumnValueFilter(
                    Bytes.toBytes("info"),
                    Bytes.toBytes("presupuesto"),
                    CompareOperator.GREATER,
                    Bytes.toBytes(presupuesto)
            );
            scan.setFilter(filter);
            
            // Obtenemos la tabla en la que ejecutar la busqueda
            Table pelsTable = con.getTable(TableName.valueOf("peliculas"));

            try (ResultScanner rs = pelsTable.getScanner(scan)) {
                for (Result filaPelicula = rs.next(); filaPelicula != null; filaPelicula = rs.next()) {
                    NavigableMap mapInfo = filaPelicula.getFamilyMap(Bytes.toBytes("info"));
                    resultado.add(
                            new Pelicula(
                                    Bytes.toInt((byte[]) mapInfo.get(Bytes.toBytes("id"))),
                                    Bytes.toString((byte[]) mapInfo.get(Bytes.toBytes("titulo"))),
                                    new Date(Bytes.toLong((byte[]) mapInfo.get(Bytes.toBytes("fechaEmision")))),
                                    Bytes.toLong((byte[]) mapInfo.get(Bytes.toBytes("presupuesto"))),
                                    Bytes.toLong((byte[]) mapInfo.get(Bytes.toBytes("ingresos"))),
                                    null,
                                    null
                            )
                    );
                }
            }
        } catch (IOException ex) {
            System.out.print("Error al consultar la tabla de películas en HBase: " + ex.getMessage() + "\n");
        }
        return resultado;
    }

    @Override
    public void ejercicio4() {
        Calendar cal1 = Calendar.getInstance();
        cal1.set(Calendar.YEAR, 2015);
        cal1.set(Calendar.MONTH, Calendar.JANUARY);
        cal1.set(Calendar.DAY_OF_MONTH, 1);
        Date start_date = cal1.getTime();
        
        Calendar cal2 = Calendar.getInstance();
        cal2.set(Calendar.YEAR, 2015);
        cal2.set(Calendar.MONTH, Calendar.JANUARY);
        cal2.set(Calendar.DAY_OF_MONTH, 31);
        Date end_date = cal2.getTime();
        

        try {
            Scan scan = new Scan();
            
            scan.addFamily(Bytes.toBytes("info"));
            scan.addFamily(Bytes.toBytes("reparto"));
            
            // Creamos los filtros
            FilterList list = new FilterList(FilterList.Operator.MUST_PASS_ALL);
            SingleColumnValueFilter filter1 = new SingleColumnValueFilter(
                    Bytes.toBytes("info"),
                    Bytes.toBytes("fechaEmision"),
                    CompareOperator.GREATER_OR_EQUAL,
                    Bytes.toBytes(start_date.getTime())
            );
            list.addFilter(filter1);
            
            SingleColumnValueFilter filter2 = new SingleColumnValueFilter(
                    Bytes.toBytes("info"),
                    Bytes.toBytes("fechaEmision"),
                    CompareOperator.LESS_OR_EQUAL,
                    Bytes.toBytes(end_date.getTime())
            );
            list.addFilter(filter2);
            
            // Añadimos los filtros al scan
            scan.setFilter(list);
            
            // Obtenemos la tabla en la que ejecutar la busqueda
            Table pelsTable = con.getTable(TableName.valueOf("peliculas"));

            try (ResultScanner rs = pelsTable.getScanner(scan)) {
                for (Result filaPelicula = rs.next(); filaPelicula != null; filaPelicula = rs.next()) {
                    NavigableMap mapInfo = filaPelicula.getFamilyMap(Bytes.toBytes("info"));
                    NavigableMap mapReparto = filaPelicula.getFamilyMap(Bytes.toBytes("reparto"));
                    
                    Reparto[] reparto = new Reparto[mapReparto.size()];

                    int i = 0;
                    for (Map.Entry<byte[], byte[]> elemReparto : (Set<Map.Entry>) mapReparto.entrySet()) {
                        reparto[i] = (Reparto) Utils.deserialize(elemReparto.getValue());
                        i++;
                    }

                    for(Reparto elemento_reparto : reparto){
                        if(elemento_reparto.getOrden() == 0){
                            System.out.println("Titulo: " + Bytes.toString((byte[]) mapInfo.get(Bytes.toBytes("titulo"))));
                            System.out.println("Nombre: " + elemento_reparto.getNombrePersona());
                            System.out.println("Personaje: " + elemento_reparto.getPersonaje());
                            System.out.println("");
                        }
                    }
                }
            }
        } catch (IOException | ClassNotFoundException ex) {
            System.out.print("Error al consultar la tabla de películas en HBase: " + ex.getMessage() + "\n");
        }
    }

    @Override
    public void ejercicio5() {
        try {
            Scan scan = new Scan();
            
            scan.addFamily(Bytes.toBytes("info"));
            scan.addFamily(Bytes.toBytes("personal"));
            
            // Obtenemos la tabla en la que ejecutar la busqueda
            Table pelsTable = con.getTable(TableName.valueOf("peliculas"));

            try (ResultScanner rs = pelsTable.getScanner(scan)) {
                for (Result filaPelicula = rs.next(); filaPelicula != null; filaPelicula = rs.next()) {
                    NavigableMap mapInfo = filaPelicula.getFamilyMap(Bytes.toBytes("info"));
                    NavigableMap mapPersonal = filaPelicula.getFamilyMap(Bytes.toBytes("personal"));
                    
                    Personal[] personal = new Personal[mapPersonal.size()];

                    int i = 0;
                    for (Map.Entry<byte[], byte[]> elemPersonal : (Set<Map.Entry>) mapPersonal.entrySet()) {
                        personal[i] = (Personal) Utils.deserialize(elemPersonal.getValue());
                        i++;
                    }

                    for(Personal elemento_personal : personal){
                        if(elemento_personal.getTrabajo().equals("Director") && elemento_personal.getNombrePersona().equals("Ridley Scott")){
                            System.out.println("Titulo: " + Bytes.toString((byte[]) mapInfo.get(Bytes.toBytes("titulo"))));
                        }
                    }
                }
            }
        } catch (IOException | ClassNotFoundException ex) {
            System.out.print("Error al consultar la tabla de películas en HBase: " + ex.getMessage() + "\n");
        }
    }
}
