package gal.usc.etse.mbd.bdge.hbasetest;

import java.util.List;

/**
 * @author alumnogreibd
 */
public interface DAOPeliculas {
    List<Pelicula> getPeliculas(int num);
    Pelicula getPelicula(int id);
    List<Reparto> getRepartoPorNombre(String nombre);
    List<Pelicula> getInfoPorPresupuesto(long presupuesto);
    void insertaPelicula(Pelicula p);
    void close();
    void ejercicio4();
    void ejercicio5();
}
