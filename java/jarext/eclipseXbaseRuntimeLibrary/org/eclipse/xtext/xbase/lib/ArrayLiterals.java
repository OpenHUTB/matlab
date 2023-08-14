// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   ArrayLiterals.java

package org.eclipse.xtext.xbase.lib;


public class ArrayLiterals
{

    public ArrayLiterals()
    {
    }

    public static Object[][] newArrayOfSize(int size0, int size1)
    {
        throw new UnsupportedOperationException("This method relies on the inlined compilation (see @Inline annotation), and cannot be used from Java or with an uncustomized interpreter.");
    }

    public static Object[] newArrayOfSize(int size)
    {
        throw new UnsupportedOperationException("This method relies on the inlined compilation (see @Inline annotation), and cannot be used from Java or with an uncustomized interpreter.");
    }

    public static char[][] newCharArrayOfSize(int size0, int size1)
    {
        return new char[size0][size1];
    }

    public static char[] newCharArrayOfSize(int size)
    {
        return new char[size];
    }

    public static int[][] newIntArrayOfSize(int size0, int size1)
    {
        return new int[size0][size1];
    }

    public static int[] newIntArrayOfSize(int size)
    {
        return new int[size];
    }

    public static boolean[][] newBooleanArrayOfSize(int size0, int size1)
    {
        return new boolean[size0][size1];
    }

    public static boolean[] newBooleanArrayOfSize(int size)
    {
        return new boolean[size];
    }

    public static short[][] newShortArrayOfSize(int size0, int size1)
    {
        return new short[size0][size1];
    }

    public static short[] newShortArrayOfSize(int size)
    {
        return new short[size];
    }

    public static long[][] newLongArrayOfSize(int size0, int size1)
    {
        return new long[size0][size1];
    }

    public static long[] newLongArrayOfSize(int size)
    {
        return new long[size];
    }

    public static float[][] newFloatArrayOfSize(int size0, int size1)
    {
        return new float[size0][size1];
    }

    public static float[] newFloatArrayOfSize(int size)
    {
        return new float[size];
    }

    public static double[][] newDoubleArrayOfSize(int size0, int size1)
    {
        return new double[size0][size1];
    }

    public static double[] newDoubleArrayOfSize(int size)
    {
        return new double[size];
    }

    public static byte[][] newByteArrayOfSize(int size0, int size1)
    {
        return new byte[size0][size1];
    }

    public static byte[] newByteArrayOfSize(int size)
    {
        return new byte[size];
    }
}
