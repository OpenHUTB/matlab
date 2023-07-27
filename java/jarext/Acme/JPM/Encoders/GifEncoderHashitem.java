// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   GifEncoder.java

package Acme.JPM.Encoders;


class GifEncoderHashitem
{

    public GifEncoderHashitem(int i, int j, int k, boolean flag)
    {
        rgb = i;
        count = j;
        index = k;
        isTransparent = flag;
    }

    public int rgb;
    public int count;
    public int index;
    public boolean isTransparent;
}
