package gal.usc.etse.mbd.bdge.hbasetest;

import java.io.ByteArrayInputStream;
import java.io.ObjectOutputStream;
import java.io.ByteArrayOutputStream;
import java.io.ObjectInputStream;

/**
 * @author alumnogreibd
 */
public class Utils {
    static byte[] serialize(Object o) throws java.io.IOException {
        ByteArrayOutputStream bs = new ByteArrayOutputStream();
        ObjectOutputStream os = new ObjectOutputStream(bs);
        os.writeObject(o);
        os.close();
        return bs.toByteArray();
    }

    static Object deserialize(byte[] b) throws java.io.IOException, ClassNotFoundException {
        Object result;
        ByteArrayInputStream bs = new ByteArrayInputStream(b);
        ObjectInputStream is = new ObjectInputStream(bs);
        result = (Object) is.readObject();
        is.close();
        return result;
    }
}
