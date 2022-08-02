package gal.usc.etse.mbd.bdge.hbasetest;

import java.io.Serializable;

/**
 * @author alumnogreibd
 */
public class Personal implements Serializable {
    private static final long serialVersionUID = 6529685098267757690L;
    
    private final int idPersona;
    private final String nombrePersona;
    private final String departamento;
    private final String trabajo;

    public Personal(int idPersona, String nombrePersona, String departamento, String trabajo) {
        this.idPersona = idPersona;
        this.nombrePersona = nombrePersona;
        this.departamento = departamento;
        this.trabajo = trabajo;
    }

    public int getIdPersona() {
        return idPersona;
    }

    public String getNombrePersona() {
        return nombrePersona;
    }

    public String getDepartamento() {
        return departamento;
    }

    public String getTrabajo() {
        return trabajo;
    }
}
