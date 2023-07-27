// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   GifEncoder.java

package Acme.JPM.Encoders;

import Acme.IntHashtable;
import java.awt.Image;
import java.awt.image.ImageProducer;
import java.io.IOException;
import java.io.OutputStream;
import java.util.Enumeration;

// Referenced classes of package Acme.JPM.Encoders:
//            ImageEncoder, GifEncoderHashitem

public class GifEncoder extends ImageEncoder
{

    void encodeStart(int i, int j)
        throws IOException
    {
        width = i;
        height = j;
        rgbPixels = new int[j][i];
    }

    void encodePixels(int i, int j, int k, int l, int ai[], int i1, int j1)
        throws IOException
    {
        for(int k1 = 0; k1 < l; k1++)
            System.arraycopy(ai, k1 * j1 + i1, rgbPixels[j + k1], i, k);

    }

    void encodeDone()
        throws IOException
    {
        int i = -1;
        int j = -1;
        colorHash = new IntHashtable();
        int k = 0;
        for(int l = 0; l < height; l++)
        {
            int i1 = l * width;
            for(int k1 = 0; k1 < width; k1++)
            {
                int l1 = rgbPixels[l][k1];
                boolean flag = l1 >>> 24 < 128;
                if(flag)
                    if(i < 0)
                    {
                        i = k;
                        j = l1;
                    } else
                    if(l1 != j)
                        rgbPixels[l][k1] = l1 = j;
                GifEncoderHashitem gifencoderhashitem = (GifEncoderHashitem)colorHash.get(l1);
                if(gifencoderhashitem == null)
                {
                    if(k >= 256)
                        throw new IOException("too many colors for a GIF");
                    gifencoderhashitem = new GifEncoderHashitem(l1, 1, k, flag);
                    k++;
                    colorHash.put(l1, gifencoderhashitem);
                } else
                {
                    gifencoderhashitem.count++;
                }
            }

        }

        byte byte0;
        if(k <= 2)
            byte0 = 1;
        else
        if(k <= 4)
            byte0 = 2;
        else
        if(k <= 16)
            byte0 = 4;
        else
            byte0 = 8;
        int j1 = 1 << byte0;
        byte abyte0[] = new byte[j1];
        byte abyte1[] = new byte[j1];
        byte abyte2[] = new byte[j1];
        for(Enumeration enumeration = colorHash.elements(); enumeration.hasMoreElements();)
        {
            GifEncoderHashitem gifencoderhashitem1 = (GifEncoderHashitem)enumeration.nextElement();
            abyte0[gifencoderhashitem1.index] = (byte)(gifencoderhashitem1.rgb >> 16 & 0xff);
            abyte1[gifencoderhashitem1.index] = (byte)(gifencoderhashitem1.rgb >> 8 & 0xff);
            abyte2[gifencoderhashitem1.index] = (byte)(gifencoderhashitem1.rgb & 0xff);
        }

        GIFEncode(out, width, height, interlace, (byte)0, i, byte0, abyte0, abyte1, abyte2);
    }

    byte GetPixel(int i, int j)
        throws IOException
    {
        GifEncoderHashitem gifencoderhashitem = (GifEncoderHashitem)colorHash.get(rgbPixels[j][i]);
        if(gifencoderhashitem == null)
            throw new IOException("color not found");
        else
            return (byte)gifencoderhashitem.index;
    }

    static void writeString(OutputStream outputstream, String s)
        throws IOException
    {
        byte abyte0[] = s.getBytes();
        outputstream.write(abyte0);
    }

    void GIFEncode(OutputStream outputstream, int i, int j, boolean flag, byte byte0, int k, int l, 
            byte abyte0[], byte abyte1[], byte abyte2[])
        throws IOException
    {
        Width = i;
        Height = j;
        Interlace = flag;
        int k1 = 1 << l;
        int j1;
        int i1 = j1 = 0;
        CountDown = i * j;
        Pass = 0;
        int l1;
        if(l <= 1)
            l1 = 2;
        else
            l1 = l;
        curx = 0;
        cury = 0;
        writeString(outputstream, "GIF89a");
        Putword(i, outputstream);
        Putword(j, outputstream);
        byte byte1 = -128;
        byte1 |= 0x70;
        byte1 |= (byte)(l - 1);
        Putbyte(byte1, outputstream);
        Putbyte(byte0, outputstream);
        Putbyte((byte)0, outputstream);
        for(int i2 = 0; i2 < k1; i2++)
        {
            Putbyte(abyte0[i2], outputstream);
            Putbyte(abyte1[i2], outputstream);
            Putbyte(abyte2[i2], outputstream);
        }

        if(k != -1)
        {
            Putbyte((byte)33, outputstream);
            Putbyte((byte)-7, outputstream);
            Putbyte((byte)4, outputstream);
            Putbyte((byte)1, outputstream);
            Putbyte((byte)0, outputstream);
            Putbyte((byte)0, outputstream);
            Putbyte((byte)k, outputstream);
            Putbyte((byte)0, outputstream);
        }
        Putbyte((byte)44, outputstream);
        Putword(i1, outputstream);
        Putword(j1, outputstream);
        Putword(i, outputstream);
        Putword(j, outputstream);
        if(flag)
            Putbyte((byte)64, outputstream);
        else
            Putbyte((byte)0, outputstream);
        Putbyte((byte)l1, outputstream);
        compress(l1 + 1, outputstream);
        Putbyte((byte)0, outputstream);
        Putbyte((byte)59, outputstream);
    }

    void BumpPixel()
    {
        curx++;
        if(curx == Width)
        {
            curx = 0;
            if(!Interlace)
                cury++;
            else
                switch(Pass)
                {
                default:
                    break;

                case 0: // '\0'
                    cury += 8;
                    if(cury >= Height)
                    {
                        Pass++;
                        cury = 4;
                    }
                    break;

                case 1: // '\001'
                    cury += 8;
                    if(cury >= Height)
                    {
                        Pass++;
                        cury = 2;
                    }
                    break;

                case 2: // '\002'
                    cury += 4;
                    if(cury >= Height)
                    {
                        Pass++;
                        cury = 1;
                    }
                    break;

                case 3: // '\003'
                    cury += 2;
                    break;
                }
        }
    }

    int GIFNextPixel()
        throws IOException
    {
        if(CountDown == 0)
        {
            return -1;
        } else
        {
            CountDown--;
            byte byte0 = GetPixel(curx, cury);
            BumpPixel();
            return byte0 & 0xff;
        }
    }

    void Putword(int i, OutputStream outputstream)
        throws IOException
    {
        Putbyte((byte)(i & 0xff), outputstream);
        Putbyte((byte)(i >> 8 & 0xff), outputstream);
    }

    void Putbyte(byte byte0, OutputStream outputstream)
        throws IOException
    {
        outputstream.write(byte0);
    }

    final int MAXCODE(int i)
    {
        return (1 << i) - 1;
    }

    void compress(int i, OutputStream outputstream)
        throws IOException
    {
        g_init_bits = i;
        clear_flg = false;
        n_bits = g_init_bits;
        maxcode = MAXCODE(n_bits);
        ClearCode = 1 << i - 1;
        EOFCode = ClearCode + 1;
        free_ent = ClearCode + 2;
        char_init();
        int j1 = GIFNextPixel();
        int i2 = 0;
        for(int j = hsize; j < 0x10000; j *= 2)
            i2++;

        i2 = 8 - i2;
        int l1 = hsize;
        cl_hash(l1);
        output(ClearCode, outputstream);
        int i1;
label0:
        while((i1 = GIFNextPixel()) != -1) 
        {
            int k = (i1 << maxbits) + j1;
            int l = i1 << i2 ^ j1;
            if(htab[l] == k)
            {
                j1 = codetab[l];
                continue;
            }
            if(htab[l] >= 0)
            {
                int k1 = l1 - l;
                if(l == 0)
                    k1 = 1;
                do
                {
                    if((l -= k1) < 0)
                        l += l1;
                    if(htab[l] == k)
                    {
                        j1 = codetab[l];
                        continue label0;
                    }
                } while(htab[l] >= 0);
            }
            output(j1, outputstream);
            j1 = i1;
            if(free_ent < maxmaxcode)
            {
                codetab[l] = free_ent++;
                htab[l] = k;
            } else
            {
                cl_block(outputstream);
            }
        }
        output(j1, outputstream);
        output(EOFCode, outputstream);
    }

    void output(int i, OutputStream outputstream)
        throws IOException
    {
        cur_accum &= masks[cur_bits];
        if(cur_bits > 0)
            cur_accum |= i << cur_bits;
        else
            cur_accum = i;
        for(cur_bits += n_bits; cur_bits >= 8; cur_bits -= 8)
        {
            char_out((byte)(cur_accum & 0xff), outputstream);
            cur_accum >>= 8;
        }

        if(free_ent > maxcode || clear_flg)
            if(clear_flg)
            {
                maxcode = MAXCODE(n_bits = g_init_bits);
                clear_flg = false;
            } else
            {
                n_bits++;
                if(n_bits == maxbits)
                    maxcode = maxmaxcode;
                else
                    maxcode = MAXCODE(n_bits);
            }
        if(i == EOFCode)
        {
            for(; cur_bits > 0; cur_bits -= 8)
            {
                char_out((byte)(cur_accum & 0xff), outputstream);
                cur_accum >>= 8;
            }

            flush_char(outputstream);
        }
    }

    void cl_block(OutputStream outputstream)
        throws IOException
    {
        cl_hash(hsize);
        free_ent = ClearCode + 2;
        clear_flg = true;
        output(ClearCode, outputstream);
    }

    void cl_hash(int i)
    {
        for(int j = 0; j < i; j++)
            htab[j] = -1;

    }

    void char_init()
    {
        a_count = 0;
    }

    void char_out(byte byte0, OutputStream outputstream)
        throws IOException
    {
        accum[a_count++] = byte0;
        if(a_count >= 254)
            flush_char(outputstream);
    }

    void flush_char(OutputStream outputstream)
        throws IOException
    {
        if(a_count > 0)
        {
            outputstream.write(a_count);
            outputstream.write(accum, 0, a_count);
            a_count = 0;
        }
    }

    public GifEncoder(Image image, OutputStream outputstream)
        throws IOException
    {
        super(image, outputstream);
        interlace = false;
        Pass = 0;
        maxbits = 12;
        maxmaxcode = 4096;
        htab = new int[5003];
        codetab = new int[5003];
        hsize = 5003;
        free_ent = 0;
        clear_flg = false;
        cur_accum = 0;
        cur_bits = 0;
        accum = new byte[256];
    }

    public GifEncoder(Image image, OutputStream outputstream, boolean flag)
        throws IOException
    {
        super(image, outputstream);
        interlace = false;
        Pass = 0;
        maxbits = 12;
        maxmaxcode = 4096;
        htab = new int[5003];
        codetab = new int[5003];
        hsize = 5003;
        free_ent = 0;
        clear_flg = false;
        cur_accum = 0;
        cur_bits = 0;
        accum = new byte[256];
        interlace = flag;
    }

    public GifEncoder(ImageProducer imageproducer, OutputStream outputstream)
        throws IOException
    {
        super(imageproducer, outputstream);
        interlace = false;
        Pass = 0;
        maxbits = 12;
        maxmaxcode = 4096;
        htab = new int[5003];
        codetab = new int[5003];
        hsize = 5003;
        free_ent = 0;
        clear_flg = false;
        cur_accum = 0;
        cur_bits = 0;
        accum = new byte[256];
    }

    public GifEncoder(ImageProducer imageproducer, OutputStream outputstream, boolean flag)
        throws IOException
    {
        super(imageproducer, outputstream);
        interlace = false;
        Pass = 0;
        maxbits = 12;
        maxmaxcode = 4096;
        htab = new int[5003];
        codetab = new int[5003];
        hsize = 5003;
        free_ent = 0;
        clear_flg = false;
        cur_accum = 0;
        cur_bits = 0;
        accum = new byte[256];
        interlace = flag;
    }

    static final int EOF = -1;
    static final int BITS = 12;
    static final int HSIZE = 5003;
    private boolean interlace;
    int width;
    int height;
    int rgbPixels[][];
    IntHashtable colorHash;
    int Width;
    int Height;
    boolean Interlace;
    int curx;
    int cury;
    int CountDown;
    int Pass;
    int n_bits;
    int maxbits;
    int maxcode;
    int maxmaxcode;
    int htab[];
    int codetab[];
    int hsize;
    int free_ent;
    boolean clear_flg;
    int g_init_bits;
    int ClearCode;
    int EOFCode;
    int cur_accum;
    int cur_bits;
    int masks[] = {
        0, 1, 3, 7, 15, 31, 63, 127, 255, 511, 
        1023, 2047, 4095, 8191, 16383, 32767, 65535
    };
    int a_count;
    byte accum[];
}
