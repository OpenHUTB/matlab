// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   ImageEncoder.java

package Acme.JPM.Encoders;

import java.awt.Image;
import java.awt.image.*;
import java.io.IOException;
import java.io.OutputStream;
import java.util.Hashtable;

public abstract class ImageEncoder
    implements ImageConsumer
{

    abstract void encodeStart(int i, int j)
        throws IOException;

    abstract void encodePixels(int i, int j, int k, int l, int ai[], int i1, int j1)
        throws IOException;

    abstract void encodeDone()
        throws IOException;

    public synchronized void encode()
        throws IOException
    {
        encoding = true;
        iox = null;
        producer.startProduction(this);
        while(encoding) 
            try
            {
                wait();
            }
            catch(InterruptedException interruptedexception) { }
        if(iox != null)
            throw iox;
        else
            return;
    }

    private void encodePixelsWrapper(int i, int j, int k, int l, int ai[], int i1, int j1)
        throws IOException
    {
        if(!started)
        {
            started = true;
            encodeStart(width, height);
            if((hintflags & 2) == 0)
            {
                accumulate = true;
                accumulator = new int[width * height];
            }
        }
        if(accumulate)
        {
            for(int k1 = 0; k1 < l; k1++)
                System.arraycopy(ai, k1 * j1 + i1, accumulator, (j + k1) * width + i, k);

        } else
        {
            encodePixels(i, j, k, l, ai, i1, j1);
        }
    }

    private void encodeFinish()
        throws IOException
    {
        if(accumulate)
        {
            encodePixels(0, 0, width, height, accumulator, 0, width);
            accumulator = null;
            accumulate = false;
        }
    }

    private synchronized void stop()
    {
        encoding = false;
        notifyAll();
    }

    public void setDimensions(int i, int j)
    {
        width = i;
        height = j;
    }

    public void setProperties(Hashtable hashtable)
    {
        props = hashtable;
    }

    public void setColorModel(ColorModel colormodel)
    {
    }

    public void setHints(int i)
    {
        hintflags = i;
    }

    public void setPixels(int i, int j, int k, int l, ColorModel colormodel, byte abyte0[], int i1, 
            int j1)
    {
        int ai[] = new int[k];
        for(int k1 = 0; k1 < l; k1++)
        {
            int l1 = i1 + k1 * j1;
            for(int i2 = 0; i2 < k; i2++)
                ai[i2] = colormodel.getRGB(abyte0[l1 + i2] & 0xff);

            try
            {
                encodePixelsWrapper(i, j + k1, k, 1, ai, 0, k);
            }
            catch(IOException ioexception)
            {
                iox = ioexception;
                stop();
                return;
            }
        }

    }

    public void setPixels(int i, int j, int k, int l, ColorModel colormodel, int ai[], int i1, 
            int j1)
    {
        if(colormodel == rgbModel)
        {
            try
            {
                encodePixelsWrapper(i, j, k, l, ai, i1, j1);
            }
            catch(IOException ioexception)
            {
                iox = ioexception;
                stop();
                return;
            }
        } else
        {
            int ai1[] = new int[k];
            for(int k1 = 0; k1 < l; k1++)
            {
                int l1 = i1 + k1 * j1;
                for(int i2 = 0; i2 < k; i2++)
                    ai1[i2] = colormodel.getRGB(ai[l1 + i2]);

                try
                {
                    encodePixelsWrapper(i, j + k1, k, 1, ai1, 0, k);
                }
                catch(IOException ioexception1)
                {
                    iox = ioexception1;
                    stop();
                    return;
                }
            }

        }
    }

    public void imageComplete(int i)
    {
        producer.removeConsumer(this);
        if(i == 4)
            iox = new IOException("image aborted");
        else
            try
            {
                encodeFinish();
                encodeDone();
            }
            catch(IOException ioexception)
            {
                iox = ioexception;
            }
        stop();
    }

    public ImageEncoder(Image image, OutputStream outputstream)
        throws IOException
    {
        this(image.getSource(), outputstream);
    }

    public ImageEncoder(ImageProducer imageproducer, OutputStream outputstream)
        throws IOException
    {
        width = -1;
        height = -1;
        hintflags = 0;
        started = false;
        props = null;
        accumulate = false;
        producer = imageproducer;
        out = outputstream;
    }

    private static final ColorModel rgbModel = ColorModel.getRGBdefault();
    protected OutputStream out;
    private ImageProducer producer;
    private int width;
    private int height;
    private int hintflags;
    private boolean started;
    private boolean encoding;
    private IOException iox;
    private Hashtable props;
    private boolean accumulate;
    private int accumulator[];

}
