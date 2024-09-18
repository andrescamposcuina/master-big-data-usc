package gal.usc.etse.mbd.bdge.hbasetest;

import java.util.Date;

/**
 * @author alumnogreibd
 */
public class Pelicula{
    private final int idPelicula;
    private final String titulo;
    private final Date fechaEmision;
    private final long ingresos;
    private final long presupuesto;
    private final Reparto[] reparto;
    private final Personal[] personal;

    public Pelicula(int idPelicula, String titulo, Date fechaEmision, long ingresos, long presupuesto, Reparto[] reparto, Personal[] personal) {
        this.idPelicula = idPelicula;
        this.titulo = titulo;
        this.fechaEmision = fechaEmision;
        this.ingresos = ingresos;
        this.presupuesto = presupuesto;
        this.reparto = reparto;
        this.personal = personal;
    }

    public int getIdPelicula() {
        return idPelicula;
    }

    public String getTitulo() {
        return titulo;
    }

    public Date getFechaEmsion() {
        return fechaEmision;
    }

    public long getIngresos() {
        return ingresos;
    }

    public long getPresupuesto() {
        return presupuesto;
    }

    public int getTamanoReparto() {
        return reparto.length;
    }

    public Reparto getReparto(int i) {
        return reparto[i];
    }

    public int getTamanoPersonal() {
        return personal.length;
    }

    public Personal getPersonal(int i) {
        return personal[i];
    }
}
