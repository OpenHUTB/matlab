// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   ShortExtensions.java

package org.eclipse.xtext.xbase.lib;


// Referenced classes of package org.eclipse.xtext.xbase.lib:
//            HardcodedInInterpreterException

public class ShortExtensions
{

    public ShortExtensions()
    {
    }

    public static int operator_minus(short s)
    {
        return -s;
    }

    public static short operator_minusMinus(short s)
    {
        throw new HardcodedInInterpreterException();
    }

    public static Short operator_minusMinus(Short s)
    {
        throw new HardcodedInInterpreterException();
    }

    public static short operator_plusPlus(short s)
    {
        throw new HardcodedInInterpreterException();
    }

    public static Short operator_plusPlus(Short s)
    {
        throw new HardcodedInInterpreterException();
    }

    public static double operator_plus(short a, double b)
    {
        return (double)a + b;
    }

    public static double operator_minus(short a, double b)
    {
        return (double)a - b;
    }

    public static double operator_multiply(short a, double b)
    {
        return (double)a * b;
    }

    public static double operator_divide(short a, double b)
    {
        return (double)a / b;
    }

    public static double operator_modulo(short a, double b)
    {
        return (double)a % b;
    }

    public static boolean operator_lessThan(short a, double b)
    {
        return (double)a < b;
    }

    public static boolean operator_lessEqualsThan(short a, double b)
    {
        return (double)a <= b;
    }

    public static boolean operator_greaterThan(short a, double b)
    {
        return (double)a > b;
    }

    public static boolean operator_greaterEqualsThan(short a, double b)
    {
        return (double)a >= b;
    }

    public static boolean operator_equals(short a, double b)
    {
        return (double)a == b;
    }

    public static boolean operator_notEquals(short a, double b)
    {
        return (double)a != b;
    }

    public static double operator_power(short a, double b)
    {
        return Math.pow(a, b);
    }

    public static boolean operator_tripleEquals(short a, double b)
    {
        return (double)a == b;
    }

    public static boolean operator_tripleNotEquals(short a, double b)
    {
        return (double)a != b;
    }

    public static float operator_plus(short a, float b)
    {
        return (float)a + b;
    }

    public static float operator_minus(short a, float b)
    {
        return (float)a - b;
    }

    public static float operator_multiply(short a, float b)
    {
        return (float)a * b;
    }

    public static float operator_divide(short a, float b)
    {
        return (float)a / b;
    }

    public static float operator_modulo(short a, float b)
    {
        return (float)a % b;
    }

    public static boolean operator_lessThan(short a, float b)
    {
        return (float)a < b;
    }

    public static boolean operator_lessEqualsThan(short a, float b)
    {
        return (float)a <= b;
    }

    public static boolean operator_greaterThan(short a, float b)
    {
        return (float)a > b;
    }

    public static boolean operator_greaterEqualsThan(short a, float b)
    {
        return (float)a >= b;
    }

    public static boolean operator_equals(short a, float b)
    {
        return (float)a == b;
    }

    public static boolean operator_notEquals(short a, float b)
    {
        return (float)a != b;
    }

    public static double operator_power(short a, float b)
    {
        return Math.pow(a, b);
    }

    public static boolean operator_tripleEquals(short a, float b)
    {
        return (float)a == b;
    }

    public static boolean operator_tripleNotEquals(short a, float b)
    {
        return (float)a != b;
    }

    public static long operator_plus(short a, long b)
    {
        return (long)a + b;
    }

    public static long operator_minus(short a, long b)
    {
        return (long)a - b;
    }

    public static long operator_multiply(short a, long b)
    {
        return (long)a * b;
    }

    public static long operator_divide(short a, long b)
    {
        return (long)a / b;
    }

    public static long operator_modulo(short a, long b)
    {
        return (long)a % b;
    }

    public static boolean operator_lessThan(short a, long b)
    {
        return (long)a < b;
    }

    public static boolean operator_lessEqualsThan(short a, long b)
    {
        return (long)a <= b;
    }

    public static boolean operator_greaterThan(short a, long b)
    {
        return (long)a > b;
    }

    public static boolean operator_greaterEqualsThan(short a, long b)
    {
        return (long)a >= b;
    }

    public static boolean operator_equals(short a, long b)
    {
        return (long)a == b;
    }

    public static boolean operator_notEquals(short a, long b)
    {
        return (long)a != b;
    }

    public static double operator_power(short a, long b)
    {
        return Math.pow(a, b);
    }

    public static boolean operator_tripleEquals(short a, long b)
    {
        return (long)a == b;
    }

    public static boolean operator_tripleNotEquals(short a, long b)
    {
        return (long)a != b;
    }

    public static int operator_plus(short a, int b)
    {
        return a + b;
    }

    public static int operator_minus(short a, int b)
    {
        return a - b;
    }

    public static int operator_multiply(short a, int b)
    {
        return a * b;
    }

    public static int operator_divide(short a, int b)
    {
        return a / b;
    }

    public static int operator_modulo(short a, int b)
    {
        return a % b;
    }

    public static boolean operator_lessThan(short a, int b)
    {
        return a < b;
    }

    public static boolean operator_lessEqualsThan(short a, int b)
    {
        return a <= b;
    }

    public static boolean operator_greaterThan(short a, int b)
    {
        return a > b;
    }

    public static boolean operator_greaterEqualsThan(short a, int b)
    {
        return a >= b;
    }

    public static boolean operator_equals(short a, int b)
    {
        return a == b;
    }

    public static boolean operator_notEquals(short a, int b)
    {
        return a != b;
    }

    public static double operator_power(short a, int b)
    {
        return Math.pow(a, b);
    }

    public static boolean operator_tripleEquals(short a, int b)
    {
        return a == b;
    }

    public static boolean operator_tripleNotEquals(short a, int b)
    {
        return a != b;
    }

    public static int operator_plus(short a, char b)
    {
        return a + b;
    }

    public static int operator_minus(short a, char b)
    {
        return a - b;
    }

    public static int operator_multiply(short a, char b)
    {
        return a * b;
    }

    public static int operator_divide(short a, char b)
    {
        return a / b;
    }

    public static int operator_modulo(short a, char b)
    {
        return a % b;
    }

    public static boolean operator_lessThan(short a, char b)
    {
        return a < b;
    }

    public static boolean operator_lessEqualsThan(short a, char b)
    {
        return a <= b;
    }

    public static boolean operator_greaterThan(short a, char b)
    {
        return a > b;
    }

    public static boolean operator_greaterEqualsThan(short a, char b)
    {
        return a >= b;
    }

    public static boolean operator_equals(short a, char b)
    {
        return a == b;
    }

    public static boolean operator_notEquals(short a, char b)
    {
        return a != b;
    }

    public static double operator_power(short a, char b)
    {
        return Math.pow(a, b);
    }

    public static boolean operator_tripleEquals(short a, char b)
    {
        return a == b;
    }

    public static boolean operator_tripleNotEquals(short a, char b)
    {
        return a != b;
    }

    public static int operator_plus(short a, short b)
    {
        return a + b;
    }

    public static int operator_minus(short a, short b)
    {
        return a - b;
    }

    public static int operator_multiply(short a, short b)
    {
        return a * b;
    }

    public static int operator_divide(short a, short b)
    {
        return a / b;
    }

    public static int operator_modulo(short a, short b)
    {
        return a % b;
    }

    public static boolean operator_lessThan(short a, short b)
    {
        return a < b;
    }

    public static boolean operator_lessEqualsThan(short a, short b)
    {
        return a <= b;
    }

    public static boolean operator_greaterThan(short a, short b)
    {
        return a > b;
    }

    public static boolean operator_greaterEqualsThan(short a, short b)
    {
        return a >= b;
    }

    public static boolean operator_equals(short a, short b)
    {
        return a == b;
    }

    public static boolean operator_notEquals(short a, short b)
    {
        return a != b;
    }

    public static double operator_power(short a, short b)
    {
        return Math.pow(a, b);
    }

    public static boolean operator_tripleEquals(short a, short b)
    {
        return a == b;
    }

    public static boolean operator_tripleNotEquals(short a, short b)
    {
        return a != b;
    }

    public static int operator_plus(short a, byte b)
    {
        return a + b;
    }

    public static int operator_minus(short a, byte b)
    {
        return a - b;
    }

    public static int operator_multiply(short a, byte b)
    {
        return a * b;
    }

    public static int operator_divide(short a, byte b)
    {
        return a / b;
    }

    public static int operator_modulo(short a, byte b)
    {
        return a % b;
    }

    public static boolean operator_lessThan(short a, byte b)
    {
        return a < b;
    }

    public static boolean operator_lessEqualsThan(short a, byte b)
    {
        return a <= b;
    }

    public static boolean operator_greaterThan(short a, byte b)
    {
        return a > b;
    }

    public static boolean operator_greaterEqualsThan(short a, byte b)
    {
        return a >= b;
    }

    public static boolean operator_equals(short a, byte b)
    {
        return a == b;
    }

    public static boolean operator_notEquals(short a, byte b)
    {
        return a != b;
    }

    public static double operator_power(short a, byte b)
    {
        return Math.pow(a, b);
    }

    public static boolean operator_tripleEquals(short a, byte b)
    {
        return a == b;
    }

    public static boolean operator_tripleNotEquals(short a, byte b)
    {
        return a != b;
    }
}
