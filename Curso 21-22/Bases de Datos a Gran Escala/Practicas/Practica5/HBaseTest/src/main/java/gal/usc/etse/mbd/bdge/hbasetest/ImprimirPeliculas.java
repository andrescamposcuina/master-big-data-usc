package gal.usc.etse.mbd.bdge.hbasetest;

import java.util.List;

/**
 * @author alumnogreibd
 */
public class ImprimirPeliculas {
    public static void imprimeTodo(List<Pelicula> pels) {
        for (Pelicula p : pels) {
            System.out.print("\n");
            System.out.printf("Titulo: %s\n", p.getTitulo());
            System.out.printf("Id: %d\n", p.getIdPelicula());
            System.out.printf("Fecha Emision: %tF\n", p.getFechaEmsion());
            System.out.printf("Presupuesto: %d\n", p.getPresupuesto());
            System.out.printf("Ingresos: %d\n", p.getIngresos());
            System.out.print("Reparto(Orden, Personaje, Id, Actriz/Actor)\n");

            for (int i = 0; i < p.getTamanoReparto(); i++) {
                System.out.printf(
                        "  %d, %s, %d, %s\n", p.getReparto(i).getOrden(),
                        p.getReparto(i).getPersonaje(),
                        p.getReparto(i).getIdPersona(),
                        p.getReparto(i).getNombrePersona()
                );
            }

            System.out.print("Personal del equipo (Departamento, Trabajo, Id, Nombre)\n");
            for (int i = 0; i < p.getTamanoPersonal(); i++) {
                System.out.printf(
                        "  %s, %s, %d, %s\n", p.getPersonal(i).getDepartamento(),
                        p.getPersonal(i).getTrabajo(),
                        p.getPersonal(i).getIdPersona(),
                        p.getPersonal(i).getNombrePersona()
                );
            }
        }
    }
    
    public static void imprime(Pelicula pelicula){
        System.out.print("\n");
        System.out.printf("Titulo: %s\n", pelicula.getTitulo());
        System.out.printf("Id: %d\n", pelicula.getIdPelicula());
        System.out.printf("Fecha Emision: %tF\n", pelicula.getFechaEmsion());
        System.out.printf("Presupuesto: %d\n", pelicula.getPresupuesto());
        System.out.printf("Ingresos: %d\n", pelicula.getIngresos());
        System.out.print("Reparto(Orden, Personaje, Id, Actriz/Actor)\n");

        for (int i = 0; i < pelicula.getTamanoReparto(); i++) {
            System.out.printf(
                    "  %d, %s, %d, %s\n", pelicula.getReparto(i).getOrden(),
                    pelicula.getReparto(i).getPersonaje(),
                    pelicula.getReparto(i).getIdPersona(),
                    pelicula.getReparto(i).getNombrePersona()
            );
        }

        System.out.print("Personal del equipo (Departamento, Trabajo, Id, Nombre)\n");
        for (int i = 0; i < pelicula.getTamanoPersonal(); i++) {
            System.out.printf(
                    "  %s, %s, %d, %s\n", pelicula.getPersonal(i).getDepartamento(),
                    pelicula.getPersonal(i).getTrabajo(),
                    pelicula.getPersonal(i).getIdPersona(),
                    pelicula.getPersonal(i).getNombrePersona()
            );
        }
    }
    
    public static void imprimeInfo(List<Pelicula> pels) {
        for (Pelicula p : pels) {
            System.out.print("\n");
            System.out.printf("Titulo: %s\n", p.getTitulo());
            System.out.printf("Id: %d\n", p.getIdPelicula());
            System.out.printf("Fecha Emision: %tF\n", p.getFechaEmsion());
            System.out.printf("Presupuesto: %d\n", p.getPresupuesto());
            System.out.printf("Ingresos: %d\n", p.getIngresos());
        }
    }
    
    public static void imprimeReparto(List<Reparto> reparto){
        for (int i = 0; i < reparto.size(); i++) {
            System.out.printf(
                    "  %d, %s, %d, %s\n", reparto.get(i).getOrden(),
                    reparto.get(i).getPersonaje(),
                    reparto.get(i).getIdPersona(),
                    reparto.get(i).getNombrePersona()
            );
        }
    }
}
