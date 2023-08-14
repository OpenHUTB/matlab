// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   ArrayExtensions.java

package org.eclipse.xtext.xbase.lib;

import java.util.Objects;

public class ArrayExtensions
{

    public ArrayExtensions()
    {
    }

    public static Object set(Object array[], int index, Object value)
    {
        array[index] = value;
        return value;
    }

    public static Object get(Object array[], int index)
    {
        return array[index];
    }

    public static Object[] clone(Object array[])
    {
        return (Object[])((Object []) (array)).clone();
    }

    public static int length(Object array[])
    {
        return array.length;
    }

    public static int hashCode(Object array[])
    {
        return ((Object) (array)).hashCode();
    }

    public static boolean equals(Object array[], Object other)
    {
        return ((Object) (array)).equals(other);
    }

    public static boolean contains(Object array[], Object o)
    {
        for(int i = 0; i < array.length; i++)
            if(Objects.equals(array[i], o))
                return true;

        return false;
    }

    public static boolean get(boolean array[], int index)
    {
        return array[index];
    }

    public static boolean set(boolean array[], int index, boolean value)
    {
        array[index] = value;
        return value;
    }

    public static int length(boolean array[])
    {
        return array.length;
    }

    public static int hashCode(boolean array[])
    {
        return array.hashCode();
    }

    public static boolean equals(boolean array[], Object other)
    {
        return array.equals(other);
    }

    public static boolean[] clone(boolean array[])
    {
        return (boolean[])array.clone();
    }

    public static boolean contains(boolean array[], boolean value)
    {
        for(int i = 0; i < array.length; i++)
            if(array[i] == value)
                return true;

        return false;
    }

    public static double get(double array[], int index)
    {
        return array[index];
    }

    public static double set(double array[], int index, double value)
    {
        array[index] = value;
        return value;
    }

    public static int length(double array[])
    {
        return array.length;
    }

    public static int hashCode(double array[])
    {
        return array.hashCode();
    }

    public static boolean equals(double array[], Object other)
    {
        return array.equals(other);
    }

    public static double[] clone(double array[])
    {
        return (double[])array.clone();
    }

    public static boolean contains(double array[], double value)
    {
        for(int i = 0; i < array.length; i++)
            if(Double.compare(array[i], value) == 0)
                return true;

        return false;
    }

    public static float get(float array[], int index)
    {
        return array[index];
    }

    public static float set(float array[], int index, float value)
    {
        array[index] = value;
        return value;
    }

    public static int length(float array[])
    {
        return array.length;
    }

    public static int hashCode(float array[])
    {
        return array.hashCode();
    }

    public static boolean equals(float array[], Object other)
    {
        return array.equals(other);
    }

    public static float[] clone(float array[])
    {
        return (float[])array.clone();
    }

    public static boolean contains(float array[], float value)
    {
        for(int i = 0; i < array.length; i++)
            if(Float.compare(array[i], value) == 0)
                return true;

        return false;
    }

    public static long get(long array[], int index)
    {
        return array[index];
    }

    public static long set(long array[], int index, long value)
    {
        array[index] = value;
        return value;
    }

    public static int length(long array[])
    {
        return array.length;
    }

    public static int hashCode(long array[])
    {
        return array.hashCode();
    }

    public static boolean equals(long array[], Object other)
    {
        return array.equals(other);
    }

    public static long[] clone(long array[])
    {
        return (long[])array.clone();
    }

    public static boolean contains(long array[], long value)
    {
        for(int i = 0; i < array.length; i++)
            if(array[i] == value)
                return true;

        return false;
    }

    public static int get(int array[], int index)
    {
        return array[index];
    }

    public static int set(int array[], int index, int value)
    {
        array[index] = value;
        return value;
    }

    public static int length(int array[])
    {
        return array.length;
    }

    public static int hashCode(int array[])
    {
        return array.hashCode();
    }

    public static boolean equals(int array[], Object other)
    {
        return array.equals(other);
    }

    public static int[] clone(int array[])
    {
        return (int[])array.clone();
    }

    public static boolean contains(int array[], int value)
    {
        for(int i = 0; i < array.length; i++)
            if(array[i] == value)
                return true;

        return false;
    }

    public static char get(char array[], int index)
    {
        return array[index];
    }

    public static char set(char array[], int index, char value)
    {
        array[index] = value;
        return value;
    }

    public static int length(char array[])
    {
        return array.length;
    }

    public static int hashCode(char array[])
    {
        return array.hashCode();
    }

    public static boolean equals(char array[], Object other)
    {
        return array.equals(other);
    }

    public static char[] clone(char array[])
    {
        return (char[])array.clone();
    }

    public static boolean contains(char array[], char value)
    {
        for(int i = 0; i < array.length; i++)
            if(array[i] == value)
                return true;

        return false;
    }

    public static short get(short array[], int index)
    {
        return array[index];
    }

    public static short set(short array[], int index, short value)
    {
        array[index] = value;
        return value;
    }

    public static int length(short array[])
    {
        return array.length;
    }

    public static int hashCode(short array[])
    {
        return array.hashCode();
    }

    public static boolean equals(short array[], Object other)
    {
        return array.equals(other);
    }

    public static short[] clone(short array[])
    {
        return (short[])array.clone();
    }

    public static boolean contains(short array[], short value)
    {
        for(int i = 0; i < array.length; i++)
            if(array[i] == value)
                return true;

        return false;
    }

    public static byte get(byte array[], int index)
    {
        return array[index];
    }

    public static byte set(byte array[], int index, byte value)
    {
        array[index] = value;
        return value;
    }

    public static int length(byte array[])
    {
        return array.length;
    }

    public static int hashCode(byte array[])
    {
        return array.hashCode();
    }

    public static boolean equals(byte array[], Object other)
    {
        return array.equals(other);
    }

    public static byte[] clone(byte array[])
    {
        return (byte[])array.clone();
    }

    public static boolean contains(byte array[], byte value)
    {
        for(int i = 0; i < array.length; i++)
            if(array[i] == value)
                return true;

        return false;
    }

    public static Object get(Object array[][], int index0, int index1)
    {
        return array[index0][index1];
    }

    public static Object set(Object array[][], int index0, int index1, Object value)
    {
        array[index0][index1] = value;
        return value;
    }

    public static boolean get(boolean array[][], int index0, int index1)
    {
        return array[index0][index1];
    }

    public static boolean set(boolean array[][], int index0, int index1, boolean value)
    {
        array[index0][index1] = value;
        return value;
    }

    public static double get(double array[][], int index0, int index1)
    {
        return array[index0][index1];
    }

    public static double set(double array[][], int index0, int index1, double value)
    {
        array[index0][index1] = value;
        return value;
    }

    public static float get(float array[][], int index0, int index1)
    {
        return array[index0][index1];
    }

    public static float set(float array[][], int index0, int index1, float value)
    {
        array[index0][index1] = value;
        return value;
    }

    public static long get(long array[][], int index0, int index1)
    {
        return array[index0][index1];
    }

    public static long set(long array[][], int index0, int index1, long value)
    {
        array[index0][index1] = value;
        return value;
    }

    public static int get(int array[][], int index0, int index1)
    {
        return array[index0][index1];
    }

    public static int set(int array[][], int index0, int index1, int value)
    {
        array[index0][index1] = value;
        return value;
    }

    public static char get(char array[][], int index0, int index1)
    {
        return array[index0][index1];
    }

    public static char set(char array[][], int index0, int index1, char value)
    {
        array[index0][index1] = value;
        return value;
    }

    public static short get(short array[][], int index0, int index1)
    {
        return array[index0][index1];
    }

    public static short set(short array[][], int index0, int index1, short value)
    {
        array[index0][index1] = value;
        return value;
    }

    public static byte get(byte array[][], int index0, int index1)
    {
        return array[index0][index1];
    }

    public static byte set(byte array[][], int index0, int index1, byte value)
    {
        array[index0][index1] = value;
        return value;
    }
}
