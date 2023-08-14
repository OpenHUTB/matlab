// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   ByteExtensions.java

package org.eclipse.xtext.xbase.lib;


// Referenced classes of package org.eclipse.xtext.xbase.lib:
//            HardcodedInInterpreterException

public class ByteExtensions
{

    public ByteExtensions()
    {
    }

    public static int operator_minus(byte b)
    {
        return -b;
    }

    public static byte operator_minusMinus(byte b)
    {
        throw new HardcodedInInterpreterException();
    }

    public static Byte operator_minusMinus(Byte b)
    {
        throw new HardcodedInInterpreterException();
    }

    public static byte operator_plusPlus(byte b)
    {
        throw new HardcodedInInterpreterException();
    }

    public static Byte operator_plusPlus(Byte b)
    {
        throw new HardcodedInInterpreterException();
    }

    public static double operator_plus(byte a, double b)
    {
        return (double)a + b;
    }

    public static double operator_minus(byte a, double b)
    {
        return (double)a - b;
    }

    public static double operator_multiply(byte a, double b)
    {
        return (double)a * b;
    }

    public static double operator_divide(byte a, double b)
    {
        return (double)a / b;
    }

    public static double operator_modulo(byte a, double b)
    {
        return (double)a % b;
    }

    public static boolean operator_lessThan(byte a, double b)
    {
        return (double)a < b;
    }

    public static boolean operator_lessEqualsThan(byte a, double b)
    {
        return (double)a <= b;
    }

    public static boolean operator_greaterThan(byte a, double b)
    {
        return (double)a > b;
    }

    public static boolean operator_greaterEqualsThan(byte a, double b)
    {
        return (double)a >= b;
    }

    public static boolean operator_equals(byte a, double b)
    {
        return (double)a == b;
    }

    public static boolean operator_notEquals(byte a, double b)
    {
        return (double)a != b;
    }

    public static double operator_power(byte a, double b)
    {
        return Math.pow(a, b);
    }

    public static boolean operator_tripleEquals(byte a, double b)
    {
        return (double)a == b;
    }

    public static boolean operator_tripleNotEquals(byte a, double b)
    {
        return (double)a != b;
    }

    public static float operator_plus(byte a, float b)
    {
        return (float)a + b;
    }

    public static float operator_minus(byte a, float b)
    {
        return (float)a - b;
    }

    public static float operator_multiply(byte a, float b)
    {
        return (float)a * b;
    }

    public static float operator_divide(byte a, float b)
    {
        return (float)a / b;
    }

    public static float operator_modulo(byte a, float b)
    {
        return (float)a % b;
    }

    public static boolean operator_lessThan(byte a, float b)
    {
        return (float)a < b;
    }

    public static boolean operator_lessEqualsThan(byte a, float b)
    {
        return (float)a <= b;
    }

    public static boolean operator_greaterThan(byte a, float b)
    {
        return (float)a > b;
    }

    public static boolean operator_greaterEqualsThan(byte a, float b)
    {
        return (float)a >= b;
    }

    public static boolean operator_equals(byte a, float b)
    {
        return (float)a == b;
    }

    public static boolean operator_notEquals(byte a, float b)
    {
        return (float)a != b;
    }

    public static double operator_power(byte a, float b)
    {
        return Math.pow(a, b);
    }

    public static boolean operator_tripleEquals(byte a, float b)
    {
        return (float)a == b;
    }

    public static boolean operator_tripleNotEquals(byte a, float b)
    {
        return (float)a != b;
    }

    public static long operator_plus(byte a, long b)
    {
        return (long)a + b;
    }

    public static long operator_minus(byte a, long b)
    {
        return (long)a - b;
    }

    public static long operator_multiply(byte a, long b)
    {
        return (long)a * b;
    }

    public static long operator_divide(byte a, long b)
    {
        return (long)a / b;
    }

    public static long operator_modulo(byte a, long b)
    {
        return (long)a % b;
    }

    public static boolean operator_lessThan(byte a, long b)
    {
        return (long)a < b;
    }

    public static boolean operator_lessEqualsThan(byte a, long b)
    {
        return (long)a <= b;
    }

    public static boolean operator_greaterThan(byte a, long b)
    {
        return (long)a > b;
    }

    public static boolean operator_greaterEqualsThan(byte a, long b)
    {
        return (long)a >= b;
    }

    public static boolean operator_equals(byte a, long b)
    {
        return (long)a == b;
    }

    public static boolean operator_notEquals(byte a, long b)
    {
        return (long)a != b;
    }

    public static double operator_power(byte a, long b)
    {
        return Math.pow(a, b);
    }

    public static boolean operator_tripleEquals(byte a, long b)
    {
        return (long)a == b;
    }

    public static boolean operator_tripleNotEquals(byte a, long b)
    {
        return (long)a != b;
    }

    public static int operator_plus(byte a, int b)
    {
        return a + b;
    }

    public static int operator_minus(byte a, int b)
    {
        return a - b;
    }

    public static int operator_multiply(byte a, int b)
    {
        return a * b;
    }

    public static int operator_divide(byte a, int b)
    {
        return a / b;
    }

    public static int operator_modulo(byte a, int b)
    {
        return a % b;
    }

    public static boolean operator_lessThan(byte a, int b)
    {
        return a < b;
    }

    public static boolean operator_lessEqualsThan(byte a, int b)
    {
        return a <= b;
    }

    public static boolean operator_greaterThan(byte a, int b)
    {
        return a > b;
    }

    public static boolean operator_greaterEqualsThan(byte a, int b)
    {
        return a >= b;
    }

    public static boolean operator_equals(byte a, int b)
    {
        return a == b;
    }

    public static boolean operator_notEquals(byte a, int b)
    {
        return a != b;
    }

    public static double operator_power(byte a, int b)
    {
        return Math.pow(a, b);
    }

    public static boolean operator_tripleEquals(byte a, int b)
    {
        return a == b;
    }

    public static boolean operator_tripleNotEquals(byte a, int b)
    {
        return a != b;
    }

    public static int operator_plus(byte a, char b)
    {
        return a + b;
    }

    public static int operator_minus(byte a, char b)
    {
        return a - b;
    }

    public static int operator_multiply(byte a, char b)
    {
        return a * b;
    }

    public static int operator_divide(byte a, char b)
    {
        return a / b;
    }

    public static int operator_modulo(byte a, char b)
    {
        return a % b;
    }

    public static boolean operator_lessThan(byte a, char b)
    {
        return a < b;
    }

    public static boolean operator_lessEqualsThan(byte a, char b)
    {
        return a <= b;
    }

    public static boolean operator_greaterThan(byte a, char b)
    {
        return a > b;
    }

    public static boolean operator_greaterEqualsThan(byte a, char b)
    {
        return a >= b;
    }

    public static boolean operator_equals(byte a, char b)
    {
        return a == b;
    }

    public static boolean operator_notEquals(byte a, char b)
    {
        return a != b;
    }

    public static double operator_power(byte a, char b)
    {
        return Math.pow(a, b);
    }

    public static boolean operator_tripleEquals(byte a, char b)
    {
        return a == b;
    }

    public static boolean operator_tripleNotEquals(byte a, char b)
    {
        return a != b;
    }

    public static int operator_plus(byte a, short b)
    {
        return a + b;
    }

    public static int operator_minus(byte a, short b)
    {
        return a - b;
    }

    public static int operator_multiply(byte a, short b)
    {
        return a * b;
    }

    public static int operator_divide(byte a, short b)
    {
        return a / b;
    }

    public static int operator_modulo(byte a, short b)
    {
        return a % b;
    }

    public static boolean operator_lessThan(byte a, short b)
    {
        return a < b;
    }

    public static boolean operator_lessEqualsThan(byte a, short b)
    {
        return a <= b;
    }

    public static boolean operator_greaterThan(byte a, short b)
    {
        return a > b;
    }

    public static boolean operator_greaterEqualsThan(byte a, short b)
    {
        return a >= b;
    }

    public static boolean operator_equals(byte a, short b)
    {
        return a == b;
    }

    public static boolean operator_notEquals(byte a, short b)
    {
        return a != b;
    }

    public static double operator_power(byte a, short b)
    {
        return Math.pow(a, b);
    }

    public static boolean operator_tripleEquals(byte a, short b)
    {
        return a == b;
    }

    public static boolean operator_tripleNotEquals(byte a, short b)
    {
        return a != b;
    }

    public static int operator_plus(byte a, byte b)
    {
        return a + b;
    }

    public static int operator_minus(byte a, byte b)
    {
        return a - b;
    }

    public static int operator_multiply(byte a, byte b)
    {
        return a * b;
    }

    public static int operator_divide(byte a, byte b)
    {
        return a / b;
    }

    public static int operator_modulo(byte a, byte b)
    {
        return a % b;
    }

    public static boolean operator_lessThan(byte a, byte b)
    {
        return a < b;
    }

    public static boolean operator_lessEqualsThan(byte a, byte b)
    {
        return a <= b;
    }

    public static boolean operator_greaterThan(byte a, byte b)
    {
        return a > b;
    }

    public static boolean operator_greaterEqualsThan(byte a, byte b)
    {
        return a >= b;
    }

    public static boolean operator_equals(byte a, byte b)
    {
        return a == b;
    }

    public static boolean operator_notEquals(byte a, byte b)
    {
        return a != b;
    }

    public static double operator_power(byte a, byte b)
    {
        return Math.pow(a, b);
    }

    public static boolean operator_tripleEquals(byte a, byte b)
    {
        return a == b;
    }

    public static boolean operator_tripleNotEquals(byte a, byte b)
    {
        return a != b;
    }
}
