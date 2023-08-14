// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   FloatExtensions.java

package org.eclipse.xtext.xbase.lib;


// Referenced classes of package org.eclipse.xtext.xbase.lib:
//            HardcodedInInterpreterException

public class FloatExtensions
{

    public FloatExtensions()
    {
    }

    public static float operator_minus(float f)
    {
        return -f;
    }

    public static float operator_minusMinus(float f)
    {
        throw new HardcodedInInterpreterException();
    }

    public static Float operator_minusMinus(Float f)
    {
        throw new HardcodedInInterpreterException();
    }

    public static float operator_plusPlus(float f)
    {
        throw new HardcodedInInterpreterException();
    }

    public static Float operator_plusPlus(Float f)
    {
        throw new HardcodedInInterpreterException();
    }

    public static double operator_plus(float a, double b)
    {
        return (double)a + b;
    }

    public static double operator_minus(float a, double b)
    {
        return (double)a - b;
    }

    public static double operator_multiply(float a, double b)
    {
        return (double)a * b;
    }

    public static double operator_divide(float a, double b)
    {
        return (double)a / b;
    }

    public static double operator_modulo(float a, double b)
    {
        return (double)a % b;
    }

    public static boolean operator_lessThan(float a, double b)
    {
        return (double)a < b;
    }

    public static boolean operator_lessEqualsThan(float a, double b)
    {
        return (double)a <= b;
    }

    public static boolean operator_greaterThan(float a, double b)
    {
        return (double)a > b;
    }

    public static boolean operator_greaterEqualsThan(float a, double b)
    {
        return (double)a >= b;
    }

    public static boolean operator_equals(float a, double b)
    {
        return (double)a == b;
    }

    public static boolean operator_notEquals(float a, double b)
    {
        return (double)a != b;
    }

    public static double operator_power(float a, double b)
    {
        return Math.pow(a, b);
    }

    public static boolean operator_tripleEquals(float a, double b)
    {
        return (double)a == b;
    }

    public static boolean operator_tripleNotEquals(float a, double b)
    {
        return (double)a != b;
    }

    public static float operator_plus(float a, float b)
    {
        return a + b;
    }

    public static float operator_minus(float a, float b)
    {
        return a - b;
    }

    public static float operator_multiply(float a, float b)
    {
        return a * b;
    }

    public static float operator_divide(float a, float b)
    {
        return a / b;
    }

    public static float operator_modulo(float a, float b)
    {
        return a % b;
    }

    public static boolean operator_lessThan(float a, float b)
    {
        return a < b;
    }

    public static boolean operator_lessEqualsThan(float a, float b)
    {
        return a <= b;
    }

    public static boolean operator_greaterThan(float a, float b)
    {
        return a > b;
    }

    public static boolean operator_greaterEqualsThan(float a, float b)
    {
        return a >= b;
    }

    public static boolean operator_equals(float a, float b)
    {
        return a == b;
    }

    public static boolean operator_notEquals(float a, float b)
    {
        return a != b;
    }

    public static double operator_power(float a, float b)
    {
        return Math.pow(a, b);
    }

    public static boolean operator_tripleEquals(float a, float b)
    {
        return a == b;
    }

    public static boolean operator_tripleNotEquals(float a, float b)
    {
        return a != b;
    }

    public static float operator_plus(float a, long b)
    {
        return a + (float)b;
    }

    public static float operator_minus(float a, long b)
    {
        return a - (float)b;
    }

    public static float operator_multiply(float a, long b)
    {
        return a * (float)b;
    }

    public static float operator_divide(float a, long b)
    {
        return a / (float)b;
    }

    public static float operator_modulo(float a, long b)
    {
        return a % (float)b;
    }

    public static boolean operator_lessThan(float a, long b)
    {
        return a < (float)b;
    }

    public static boolean operator_lessEqualsThan(float a, long b)
    {
        return a <= (float)b;
    }

    public static boolean operator_greaterThan(float a, long b)
    {
        return a > (float)b;
    }

    public static boolean operator_greaterEqualsThan(float a, long b)
    {
        return a >= (float)b;
    }

    public static boolean operator_equals(float a, long b)
    {
        return a == (float)b;
    }

    public static boolean operator_notEquals(float a, long b)
    {
        return a != (float)b;
    }

    public static double operator_power(float a, long b)
    {
        return Math.pow(a, b);
    }

    public static boolean operator_tripleEquals(float a, long b)
    {
        return a == (float)b;
    }

    public static boolean operator_tripleNotEquals(float a, long b)
    {
        return a != (float)b;
    }

    public static float operator_plus(float a, int b)
    {
        return a + (float)b;
    }

    public static float operator_minus(float a, int b)
    {
        return a - (float)b;
    }

    public static float operator_multiply(float a, int b)
    {
        return a * (float)b;
    }

    public static float operator_divide(float a, int b)
    {
        return a / (float)b;
    }

    public static float operator_modulo(float a, int b)
    {
        return a % (float)b;
    }

    public static boolean operator_lessThan(float a, int b)
    {
        return a < (float)b;
    }

    public static boolean operator_lessEqualsThan(float a, int b)
    {
        return a <= (float)b;
    }

    public static boolean operator_greaterThan(float a, int b)
    {
        return a > (float)b;
    }

    public static boolean operator_greaterEqualsThan(float a, int b)
    {
        return a >= (float)b;
    }

    public static boolean operator_equals(float a, int b)
    {
        return a == (float)b;
    }

    public static boolean operator_notEquals(float a, int b)
    {
        return a != (float)b;
    }

    public static double operator_power(float a, int b)
    {
        return Math.pow(a, b);
    }

    public static boolean operator_tripleEquals(float a, int b)
    {
        return a == (float)b;
    }

    public static boolean operator_tripleNotEquals(float a, int b)
    {
        return a != (float)b;
    }

    public static float operator_plus(float a, char b)
    {
        return a + (float)b;
    }

    public static float operator_minus(float a, char b)
    {
        return a - (float)b;
    }

    public static float operator_multiply(float a, char b)
    {
        return a * (float)b;
    }

    public static float operator_divide(float a, char b)
    {
        return a / (float)b;
    }

    public static float operator_modulo(float a, char b)
    {
        return a % (float)b;
    }

    public static boolean operator_lessThan(float a, char b)
    {
        return a < (float)b;
    }

    public static boolean operator_lessEqualsThan(float a, char b)
    {
        return a <= (float)b;
    }

    public static boolean operator_greaterThan(float a, char b)
    {
        return a > (float)b;
    }

    public static boolean operator_greaterEqualsThan(float a, char b)
    {
        return a >= (float)b;
    }

    public static boolean operator_equals(float a, char b)
    {
        return a == (float)b;
    }

    public static boolean operator_notEquals(float a, char b)
    {
        return a != (float)b;
    }

    public static double operator_power(float a, char b)
    {
        return Math.pow(a, b);
    }

    public static boolean operator_tripleEquals(float a, char b)
    {
        return a == (float)b;
    }

    public static boolean operator_tripleNotEquals(float a, char b)
    {
        return a != (float)b;
    }

    public static float operator_plus(float a, short b)
    {
        return a + (float)b;
    }

    public static float operator_minus(float a, short b)
    {
        return a - (float)b;
    }

    public static float operator_multiply(float a, short b)
    {
        return a * (float)b;
    }

    public static float operator_divide(float a, short b)
    {
        return a / (float)b;
    }

    public static float operator_modulo(float a, short b)
    {
        return a % (float)b;
    }

    public static boolean operator_lessThan(float a, short b)
    {
        return a < (float)b;
    }

    public static boolean operator_lessEqualsThan(float a, short b)
    {
        return a <= (float)b;
    }

    public static boolean operator_greaterThan(float a, short b)
    {
        return a > (float)b;
    }

    public static boolean operator_greaterEqualsThan(float a, short b)
    {
        return a >= (float)b;
    }

    public static boolean operator_equals(float a, short b)
    {
        return a == (float)b;
    }

    public static boolean operator_notEquals(float a, short b)
    {
        return a != (float)b;
    }

    public static double operator_power(float a, short b)
    {
        return Math.pow(a, b);
    }

    public static boolean operator_tripleEquals(float a, short b)
    {
        return a == (float)b;
    }

    public static boolean operator_tripleNotEquals(float a, short b)
    {
        return a != (float)b;
    }

    public static float operator_plus(float a, byte b)
    {
        return a + (float)b;
    }

    public static float operator_minus(float a, byte b)
    {
        return a - (float)b;
    }

    public static float operator_multiply(float a, byte b)
    {
        return a * (float)b;
    }

    public static float operator_divide(float a, byte b)
    {
        return a / (float)b;
    }

    public static float operator_modulo(float a, byte b)
    {
        return a % (float)b;
    }

    public static boolean operator_lessThan(float a, byte b)
    {
        return a < (float)b;
    }

    public static boolean operator_lessEqualsThan(float a, byte b)
    {
        return a <= (float)b;
    }

    public static boolean operator_greaterThan(float a, byte b)
    {
        return a > (float)b;
    }

    public static boolean operator_greaterEqualsThan(float a, byte b)
    {
        return a >= (float)b;
    }

    public static boolean operator_equals(float a, byte b)
    {
        return a == (float)b;
    }

    public static boolean operator_notEquals(float a, byte b)
    {
        return a != (float)b;
    }

    public static double operator_power(float a, byte b)
    {
        return Math.pow(a, b);
    }

    public static boolean operator_tripleEquals(float a, byte b)
    {
        return a == (float)b;
    }

    public static boolean operator_tripleNotEquals(float a, byte b)
    {
        return a != (float)b;
    }
}
