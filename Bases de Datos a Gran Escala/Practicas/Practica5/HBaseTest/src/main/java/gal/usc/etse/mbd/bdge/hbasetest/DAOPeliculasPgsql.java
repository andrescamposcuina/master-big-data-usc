package gal.usc.etse.mbd.bdge.hbasetest;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;

/**
 * @author alumnogreibd
 */
public class DAOPeliculasPgsql implements DAOPeliculas {
    Connection con;

    public DAOPeliculasPgsql(String servidor, String puerto, String baseDatos, String usuario, String clave) {
        try {
            Properties propUsuario = new Properties();

            propUsuario.setProperty("user", usuario);
            propUsuario.setProperty("password", clave);

            this.con = DriverManager.getConnection(
                    "jdbc:postgresql://" +
                    servidor + ":" +
                    puerto + "/" +
                    baseDatos,
                    propUsuario
            );
        } catch (SQLException ex) {
            System.out.print("Error conectando a la base de datos postgesql:" + ex.getMessage() + "\n");
        }
    }

    @Override
    public void close() {
        try {
            con.close();
        } catch (SQLException ex) {
            System.out.print("Error desconectando de la base de datos postgesql:" + ex.getMessage() + "\n");
        }
    }

    @Override
    public List<Pelicula> getPeliculas(int num) {
        List<Pelicula> resultado = new ArrayList<>();
        List<Reparto> reparto = new ArrayList<>();
        List<Personal> personal = new ArrayList<>();

        PreparedStatement stmPeliculas = null;
        ResultSet rsPeliculas;
        PreparedStatement stmReparto;
        ResultSet rsReparto;
        PreparedStatement stmPersonal;
        ResultSet rsPersonal;

        try {
            String consultaPeliculas =
                    "select *\n" +
                    "from \n" +
                    "(select id as id_pelicula,\n" +
                    "       titulo,       \n" +
                    "       presupuesto,\n" +
                    "       ingresos,\n" +
                    "       fecha_emision\n" +
                    "from peliculas \n" +
                    "where fecha_emision is not null \n" +
                    "order by presupuesto desc, id\n" +
                    "limit ?) as t\n" +
                    "order by id_pelicula";

            stmPeliculas = con.prepareStatement(consultaPeliculas);
            stmPeliculas.setLong(1, num);
            rsPeliculas = stmPeliculas.executeQuery();

            while (rsPeliculas.next()) {
                //Generamos el reparto
                String consultaReparto =
                        "select  pr.orden as orden,\n" +
                        "        pr.personaje as personaje,\n" +
                        "        p.id as id_persona,\n" +
                        "        p.nombre as nombre_persona\n" +
                        "from pelicula_reparto pr, personas p \n" +
                        "where pr.persona = p.id  and pr.pelicula = ?\n" +
                        "order by orden";

                stmReparto = con.prepareStatement(consultaReparto);
                stmReparto.setLong(1, rsPeliculas.getLong("id_pelicula"));
                rsReparto = stmReparto.executeQuery();

                while (rsReparto.next()) {
                    reparto.add(
                            new Reparto(rsReparto.getInt("orden"),
                            rsReparto.getString("personaje"),
                            rsReparto.getInt("id_persona"),
                            rsReparto.getString("nombre_persona"))
                    );
                }

                //Generamos el personal
                String consultaPersonal =
                        "select  p.id as id_persona,\n" +
                        "p.nombre as nombre_persona,\n" +
                        "pp.departamento as departamento,\n" +
                        "pp.trabajo as trabajo\n" +
                        "from pelicula_personal pp, personas p \n" +
                        "where pp.persona = p.id  and pp.pelicula = ?";

                stmPersonal = con.prepareStatement(consultaPersonal);
                stmPersonal.setLong(1, rsPeliculas.getLong("id_pelicula"));
                rsPersonal = stmPersonal.executeQuery();

                while (rsPersonal.next()) {
                    personal.add(
                            new Personal(rsPersonal.getInt("id_persona"),
                            rsPersonal.getString("nombre_persona"),
                            rsPersonal.getString("departamento"),
                            rsPersonal.getString("trabajo"))
                    );
                }

                resultado.add(
                        new Pelicula(rsPeliculas.getInt("id_pelicula"),
                        rsPeliculas.getString("titulo"),
                        rsPeliculas.getDate("fecha_emision"),
                        rsPeliculas.getLong("ingresos"),
                        rsPeliculas.getLong("presupuesto"),
                        reparto.toArray(new Reparto[0]),
                        personal.toArray(new Personal[0]))
                );

                reparto.clear();
                personal.clear();
            }
        } catch (SQLException ex) {
            System.out.print("Error querying PostgreSQL database: " + ex.getMessage() + "\n");
        } finally {
            try {
                assert stmPeliculas != null;
                stmPeliculas.close();
            } catch (SQLException ex) {
                System.out.print("Imposible cerrar cursores: " + ex.getMessage() + "\n");
            }
        }
        return resultado;
    }
    
    @Override
    public Pelicula getPelicula(int id) {
        Pelicula resultado = null;
        List<Reparto> reparto = new ArrayList<>();
        List<Personal> personal = new ArrayList<>();

        PreparedStatement stmPeliculas = null;
        ResultSet rsPeliculas;
        PreparedStatement stmReparto;
        ResultSet rsReparto;
        PreparedStatement stmPersonal;
        ResultSet rsPersonal;

        try {
            String consultaPeliculas =
                    "select *\n" +
                    "from \n" +
                    "(select id as id_pelicula,\n" +
                    "       titulo,       \n" +
                    "       presupuesto,\n" +
                    "       ingresos,\n" +
                    "       fecha_emision\n" +
                    "from peliculas \n" +
                    "where fecha_emision is not null \n" +
                    "   and id = ?\n" +
                    "order by presupuesto desc, id) as t\n" +
                    "order by id_pelicula";

            stmPeliculas = con.prepareStatement(consultaPeliculas);
            stmPeliculas.setLong(1, id);
            rsPeliculas = stmPeliculas.executeQuery();

            while (rsPeliculas.next()) {
                
                //Generamos el reparto
                String consultaReparto =
                        "select  pr.orden as orden,\n" +
                        "        pr.personaje as personaje,\n" +
                        "        p.id as id_persona,\n" +
                        "        p.nombre as nombre_persona\n" +
                        "from pelicula_reparto pr, personas p \n" +
                        "where pr.persona = p.id  and pr.pelicula = ?\n" +
                        "order by orden";

                stmReparto = con.prepareStatement(consultaReparto);
                stmReparto.setLong(1, rsPeliculas.getLong("id_pelicula"));
                rsReparto = stmReparto.executeQuery();

                while (rsReparto.next()) {
                    reparto.add(
                            new Reparto(rsReparto.getInt("orden"),
                            rsReparto.getString("personaje"),
                            rsReparto.getInt("id_persona"),
                            rsReparto.getString("nombre_persona"))
                    );
                }

                //Generamos el personal
                String consultaPersonal =
                        "select  p.id as id_persona,\n" +
                        "p.nombre as nombre_persona,\n" +
                        "pp.departamento as departamento,\n" +
                        "pp.trabajo as trabajo\n" +
                        "from pelicula_personal pp, personas p \n" +
                        "where pp.persona = p.id  and pp.pelicula = ?";

                stmPersonal = con.prepareStatement(consultaPersonal);
                stmPersonal.setLong(1, rsPeliculas.getLong("id_pelicula"));
                rsPersonal = stmPersonal.executeQuery();

                while (rsPersonal.next()) {
                    personal.add(
                            new Personal(rsPersonal.getInt("id_persona"),
                            rsPersonal.getString("nombre_persona"),
                            rsPersonal.getString("departamento"),
                            rsPersonal.getString("trabajo"))
                    );
                }

                resultado = new Pelicula(
                        rsPeliculas.getInt("id_pelicula"),
                        rsPeliculas.getString("titulo"),
                        rsPeliculas.getDate("fecha_emision"),
                        rsPeliculas.getLong("ingresos"),
                        rsPeliculas.getLong("presupuesto"),
                        reparto.toArray(new Reparto[0]),
                        personal.toArray(new Personal[0])
                );

                reparto.clear();
                personal.clear();
            }
        } catch (SQLException ex) {
            System.out.print("Error querying PostgreSQL database: " + ex.getMessage() + "\n");
        } finally {
            try {
                assert stmPeliculas != null;
                stmPeliculas.close();
            } catch (SQLException ex) {
                System.out.print("Imposible cerrar cursores: " + ex.getMessage() + "\n");
            }
        }
        return resultado;
    }

    @Override
    public void insertaPelicula(Pelicula p) {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    @Override
    public List<Reparto> getRepartoPorNombre(String nombre) {
        List<Reparto> reparto = new ArrayList<>();
        
        PreparedStatement stmReparto = null;
        ResultSet rsReparto = null;

        try {               
            // Obtenemos el reparto
            String consultaReparto =
                    "select\n" +
                    " pr.orden as orden,\n" +
                    " pr.personaje as personaje,\n" +
                    " per.id as id_persona,\n" +
                    " per.nombre as nombre_persona\n" +
                    "from pelicula_reparto pr, personas per, peliculas as pel\n" +
                    "where \n" +
                    " pr.persona = per.id\n" +
                    " and pr.pelicula = pel.id\n" +
                    " and pel.titulo = ?\n" +
                    "order by orden";

            stmReparto = con.prepareStatement(consultaReparto);
            stmReparto.setString(1, nombre);
            rsReparto = stmReparto.executeQuery();

            while (rsReparto.next()) {
                reparto.add(
                        new Reparto(rsReparto.getInt("orden"),
                        rsReparto.getString("personaje"),
                        rsReparto.getInt("id_persona"),
                        rsReparto.getString("nombre_persona"))
                );
            }         
        } catch (SQLException ex) {
            System.out.print("Error querying PostgreSQL database: " + ex.getMessage() + "\n");
        } finally {
            try {
                assert stmReparto != null;
                stmReparto.close();
            } catch (SQLException ex) {
                System.out.print("Imposible cerrar cursores: " + ex.getMessage() + "\n");
            }
        }
        return reparto;
    }

    @Override
    public List<Pelicula> getInfoPorPresupuesto(long presupuesto) {
        List<Pelicula> resultado = new ArrayList<>();

        PreparedStatement stmPeliculas = null;
        ResultSet rsPeliculas;

        try {
            String consultaPeliculas =
                    "select \n" +
                    " id as id_pelicula,\n" +
                    " titulo,       \n" +
                    " presupuesto,\n" +
                    " ingresos,\n" +
                    " fecha_emision\n" +
                    "from \n" +
                    " peliculas \n" +
                    "where \n" +
                    " fecha_emision is not null\n" +
                    " and presupuesto > ?\n" +
                    "order by presupuesto desc";

            stmPeliculas = con.prepareStatement(consultaPeliculas);
            stmPeliculas.setLong(1, presupuesto);
            rsPeliculas = stmPeliculas.executeQuery();

            while (rsPeliculas.next()) {
                resultado.add(
                        new Pelicula(
                                rsPeliculas.getInt("id_pelicula"),
                                rsPeliculas.getString("titulo"),
                                rsPeliculas.getDate("fecha_emision"),
                                rsPeliculas.getLong("ingresos"),
                                rsPeliculas.getLong("presupuesto"),
                                null,
                                null
                        )
                );
            }
        } catch (SQLException ex) {
            System.out.print("Error querying PostgreSQL database: " + ex.getMessage() + "\n");
        } finally {
            try {
                assert stmPeliculas != null;
                stmPeliculas.close();
            } catch (SQLException ex) {
                System.out.print("Imposible cerrar cursores: " + ex.getMessage() + "\n");
            }
        }
        return resultado;
    }
    
    @Override
    public void ejercicio4(){
        PreparedStatement stmPeliculas = null;
        ResultSet rsPeliculas;

        try {
            String consultaPeliculas =
                    "select\n" +
                    " pel.titulo,\n" +
                    " per.nombre,\n" +
                    " pr.personaje \n" +
                    "from \n" +
                    " peliculas as pel, \n" +
                    " personas as per, \n" +
                    " pelicula_reparto as pr\n" +
                    "where\n" +
                    " pr.pelicula = pel.id\n" +
                    " and pr.persona = per.id\n" +
                    " and extract(month from pel.fecha_emision) = 1\n" +
                    " and extract (year from pel.fecha_emision) = 2015\n" +
                    " and pr.orden = 0";

            stmPeliculas = con.prepareStatement(consultaPeliculas);
            rsPeliculas = stmPeliculas.executeQuery();

            System.out.println("Título y el protagonista principal de las películas de enero del 2015: ");
            while (rsPeliculas.next()) {
                System.out.println("Pelicula: " + rsPeliculas.getString("titulo"));
                System.out.println("Nombre: " + rsPeliculas.getString("nombre"));
                System.out.println("Personaje: " + rsPeliculas.getString("personaje"));
                System.out.println("");
            }
        } catch (SQLException ex) {
            System.out.print("Error querying PostgreSQL database: " + ex.getMessage() + "\n");
        } finally {
            try {
                assert stmPeliculas != null;
                stmPeliculas.close();
            } catch (SQLException ex) {
                System.out.print("Imposible cerrar cursores: " + ex.getMessage() + "\n");
            }
        }
    }

    @Override
    public void ejercicio5() {
        PreparedStatement stmPeliculas = null;
        ResultSet rsPeliculas;

        try {
            String consultaPeliculas =
                    "select\n" +
                    "  pel.titulo\n" +
                    " from\n" +
                    "  peliculas as pel, \n" +
                    "  personas as per, \n" +
                    "  pelicula_personal as pp\n" +
                    " where\n" +
                    "  pp.pelicula = pel.id\n" +
                    "  and pp.persona = per.id\n" +
                    "  and pp.trabajo = 'Director'\n" +
                    "  and per.nombre = 'Ridley Scott'";

            stmPeliculas = con.prepareStatement(consultaPeliculas);
            rsPeliculas = stmPeliculas.executeQuery();

            System.out.println("Títulos de las películas dirigidas por Ridley Scott: ");
            while (rsPeliculas.next()) {
                System.out.println("Pelicula: " + rsPeliculas.getString("titulo"));
            }
        } catch (SQLException ex) {
            System.out.print("Error querying PostgreSQL database: " + ex.getMessage() + "\n");
        } finally {
            try {
                assert stmPeliculas != null;
                stmPeliculas.close();
            } catch (SQLException ex) {
                System.out.print("Imposible cerrar cursores: " + ex.getMessage() + "\n");
            }
        }
    }
}
