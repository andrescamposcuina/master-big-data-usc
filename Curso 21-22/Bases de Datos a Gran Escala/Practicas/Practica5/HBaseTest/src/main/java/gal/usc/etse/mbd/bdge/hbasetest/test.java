package gal.usc.etse.mbd.bdge.hbasetest;

import java.util.List;

/**
 * @author alumnogreibd
 */
public class test {
    public static void main(String[] args) {
        // testPostgresql();
        // testInsercionHBase();
        // testImpresion();
        // testConsultaHBase();
        
        // Ejercicio 1:
        // ejercicio1Pgsql();
        // ejercicio1HBase();
        
        // Ejercicio 2:
        // ejercicio2Pgsql();
        // ejercicio2HBase();
        
        // Ejercicio 3:
        // ejercicio3Pgsql();
        // ejercicio3HBase();
        
        // Ejercicio 4:
        // ejercicio4Pgsql();
        // ejercicio4HBase();
        
        // Ejercicio 5:
        // ejercicio5Pgsql();
        // ejercicio5HBase();
    }

    private static void testPostgresql() {
        DAOPeliculas daop = new DAOPeliculasPgsql("localhost", "5432", "bdge", "alumnogreibd", "greibd2021");
        List<Pelicula> pels = daop.getPeliculas(1000);
        pels.forEach(p -> {
            System.out.print(p.getIdPelicula() + ", " + p.getTitulo() + "\n");
        });
        daop.close();
    }

    private static void testInsercionHBase() {
        DAOPeliculas daopsql = new DAOPeliculasPgsql("localhost", "5432", "bdge", "alumnogreibd", "greibd2021");
        List<Pelicula> pels = daopsql.getPeliculas(45433);
        DAOPeliculas daohbase = new DAOPeliculasHBase();

        pels.forEach(p -> {
            daohbase.insertaPelicula(p);
        });

        daopsql.close();
        daohbase.close();
    }

    private static void testConsultaHBase() {
        DAOPeliculas daohbase = new DAOPeliculasHBase();
        List<Pelicula> pels = daohbase.getPeliculas(2);
        ImprimirPeliculas.imprimeTodo(pels);
        daohbase.close();
    }

    private static void testImpresion() {
        DAOPeliculas daopsql = new DAOPeliculasPgsql("localhost", "5432", "bdge", "alumnogreibd", "greibd2021");
        List<Pelicula> pels = daopsql.getPeliculas(1);
        ImprimirPeliculas.imprimeTodo(pels);
        daopsql.close();
    }
    
    private static void ejercicio1Pgsql(){
        DAOPeliculas daopsql = new DAOPeliculasPgsql("localhost", "5432", "bdge", "alumnogreibd", "greibd2021");
        Pelicula pel = daopsql.getPelicula(1865);
        
        // Imprimimos los datos de esta pelicula
        ImprimirPeliculas.imprime(pel);
        
        // Cerramos la conexion
        daopsql.close();
    }
    
    private static void ejercicio1HBase(){
        DAOPeliculas daohbase = new DAOPeliculasHBase();
        Pelicula pel = daohbase.getPelicula(1865);
        
        // Imprimimos los datos de esta pelicula
        ImprimirPeliculas.imprime(pel);
        
        // Cerramos la conexion
        daohbase.close();
    }
    
    private static void ejercicio2Pgsql(){
        DAOPeliculas daopsql = new DAOPeliculasPgsql("localhost", "5432", "bdge", "alumnogreibd", "greibd2021");
        List<Reparto> reparto = daopsql.getRepartoPorNombre("Avatar");
                    
        // Imprimimos los datos del reparto
        System.out.println("Reparto de la película " + "Avatar" + ":");
        ImprimirPeliculas.imprimeReparto(reparto);
        
        // Cerramos la conexion
        daopsql.close();
    }
    
    private static void ejercicio2HBase(){
        DAOPeliculas daohbase = new DAOPeliculasHBase();
        List<Reparto> reparto = daohbase.getRepartoPorNombre("Avatar");
         
        // Imprimimos los datos del reparto
        System.out.println("Reparto de la película " + "Avatar" + ":");
        ImprimirPeliculas.imprimeReparto(reparto);
        
        // Cerramos la conexion
        daohbase.close();
    }
    
    private static void ejercicio3Pgsql(){
        DAOPeliculas daopsql = new DAOPeliculasPgsql("localhost", "5432", "bdge", "alumnogreibd", "greibd2021");
        List<Pelicula> peliculas = daopsql.getInfoPorPresupuesto(250000000);
        
        // Imprimimos los datos del reparto
        System.out.println("Info de las películas con más de " + 250000000 + " de presupuesto:");
        ImprimirPeliculas.imprimeInfo(peliculas);
        
        // Cerramos la conexion
        daopsql.close();
    }
    
    private static void ejercicio3HBase(){
        DAOPeliculas daohbase = new DAOPeliculasHBase();
        List<Pelicula> peliculas = daohbase.getInfoPorPresupuesto(250000000);
        
        // Imprimimos los datos del reparto
        System.out.println("Info de las películas con más de " + 250000000 + " de presupuesto:");
        ImprimirPeliculas.imprimeInfo(peliculas);
        
        // Cerramos la conexion
        daohbase.close();
    }
    
    private static void ejercicio4Pgsql(){
        DAOPeliculas daopsql = new DAOPeliculasPgsql("localhost", "5432", "bdge", "alumnogreibd", "greibd2021");
        daopsql.ejercicio4();
       
        // Cerramos la conexion
        daopsql.close();
    }
    
    private static void ejercicio4HBase(){
        DAOPeliculas daohbase = new DAOPeliculasHBase();
        daohbase.ejercicio4();
        
        // Cerramos la conexion
        daohbase.close();
    }
    
    private static void ejercicio5Pgsql(){
        DAOPeliculas daopsql = new DAOPeliculasPgsql("localhost", "5432", "bdge", "alumnogreibd", "greibd2021");
        daopsql.ejercicio5();
       
        // Cerramos la conexion
        daopsql.close();
    }
    
    private static void ejercicio5HBase(){
        DAOPeliculas daohbase = new DAOPeliculasHBase();
        daohbase.ejercicio5();
        
        // Cerramos la conexion
        daohbase.close();
    }
}

