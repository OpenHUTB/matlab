// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   PpmEncoder.java

package Acme.JPM.Encoders;

import java.awt.Image;
import java.awt.image.ImageProducer;
import java.io.IOException;
import java.io.OutputStream;

// Referenced classes of package Acme.JPM.Encoders:
//            ImageEncoder

public class PpmEncoder extends ImageEncoder
{

    void encodeStart(int i, int j)
        throws IOException
    {
        writeString(out, "P6\n");
        writeString(out, i + " " + j + "\n");
        writeString(out, "255\n");
    }

    static void writeString(OutputStream outputstream, String s)
        throws IOException
    {
        byte abyte0[] = s.getBytes();
        outputstream.write(abyte0);
    }

    void encodePixels(int i, int j, int k, int l, int ai[], int i1, int j1)
        throws IOException
    {
        byte abyte0[] = new byte[k * 3];
        for(int k1 = 0; k1 < l; k1++)
        {
            int l1 = i1 + k1 * j1;
            for(int i2 = 0; i2 < k; i2++)
            {
                int j2 = l1 + i2;
                int k2 = i2 * 3;
                abyte0[k2] = (byte)((ai[j2] & 0xff0000) >> 16);
                abyte0[k2 + 1] = (byte)((ai[j2] & 0xff00) >> 8);
                abyte0[k2 + 2] = (byte)(ai[j2] & 0xff);
            }

            out.write(abyte0);
        }

    }

    void encodeDone()
        throws IOException
    {
    }

    public PpmEncoder(Image image, OutputStream outputstream)
        throws IOException
    {
        super(image, outputstream);
    }

    public PpmEncoder(ImageProducer imageproducer, OutputStream outputstream)
        throws IOException
    {
        super(imageproducer, outputstream);
    }
}
