package gal.usc.etse.mbd.bdge.hbasetest;

import java.io.Serializable;

/**
 * @author alumnogreibd
 */
public class Reparto implements Serializable {
    private static final long serialVersionUID = 6529685098267757690L;
    
    private final int orden;
    private final String personaje;
    private final int idPersona;
    private final String nombrePersona;

    public Reparto(int orden, String personaje, int idPersona, String nombrePersona) {
        this.orden = orden;
        this.personaje = personaje;
        this.idPersona = idPersona;
        this.nombrePersona = nombrePersona;
    }

    public int getOrden() {
        return orden;
    }

    public String getPersonaje() {
        return personaje;
    }

    public int getIdPersona() {
        return idPersona;
    }

    public String getNombrePersona() {
        return nombrePersona;
    }
}
