// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   DoubleExtensions.java

package org.eclipse.xtext.xbase.lib;


// Referenced classes of package org.eclipse.xtext.xbase.lib:
//            HardcodedInInterpreterException

public class DoubleExtensions
{

    public DoubleExtensions()
    {
    }

    public static double operator_minus(Double a)
    {
        return -a.doubleValue();
    }

    public static double operator_plus(Double a, Number b)
    {
        return a.doubleValue() + b.doubleValue();
    }

    public static double operator_minus(Double a, Number b)
    {
        return a.doubleValue() - b.doubleValue();
    }

    public static double operator_power(Double a, Number b)
    {
        return Math.pow(a.doubleValue(), b.doubleValue());
    }

    public static double operator_multiply(Double a, Number b)
    {
        return a.doubleValue() * b.doubleValue();
    }

    public static double operator_divide(Double a, Number b)
    {
        return a.doubleValue() / b.doubleValue();
    }

    public static double operator_minus(double d)
    {
        return -d;
    }

    public static double operator_minusMinus(double d)
    {
        throw new HardcodedInInterpreterException();
    }

    public static Double operator_minusMinus(Double d)
    {
        throw new HardcodedInInterpreterException();
    }

    public static double operator_plusPlus(double d)
    {
        throw new HardcodedInInterpreterException();
    }

    public static Double operator_plusPlus(Double d)
    {
        throw new HardcodedInInterpreterException();
    }

    public static double operator_plus(double a, double b)
    {
        return a + b;
    }

    public static double operator_minus(double a, double b)
    {
        return a - b;
    }

    public static double operator_multiply(double a, double b)
    {
        return a * b;
    }

    public static double operator_divide(double a, double b)
    {
        return a / b;
    }

    public static double operator_modulo(double a, double b)
    {
        return a % b;
    }

    public static boolean operator_lessThan(double a, double b)
    {
        return a < b;
    }

    public static boolean operator_lessEqualsThan(double a, double b)
    {
        return a <= b;
    }

    public static boolean operator_greaterThan(double a, double b)
    {
        return a > b;
    }

    public static boolean operator_greaterEqualsThan(double a, double b)
    {
        return a >= b;
    }

    public static boolean operator_equals(double a, double b)
    {
        return a == b;
    }

    public static boolean operator_notEquals(double a, double b)
    {
        return a != b;
    }

    public static double operator_power(double a, double b)
    {
        return Math.pow(a, b);
    }

    public static boolean operator_tripleEquals(double a, double b)
    {
        return a == b;
    }

    public static boolean operator_tripleNotEquals(double a, double b)
    {
        return a != b;
    }

    public static double operator_plus(double a, float b)
    {
        return a + (double)b;
    }

    public static double operator_minus(double a, float b)
    {
        return a - (double)b;
    }

    public static double operator_multiply(double a, float b)
    {
        return a * (double)b;
    }

    public static double operator_divide(double a, float b)
    {
        return a / (double)b;
    }

    public static double operator_modulo(double a, float b)
    {
        return a % (double)b;
    }

    public static boolean operator_lessThan(double a, float b)
    {
        return a < (double)b;
    }

    public static boolean operator_lessEqualsThan(double a, float b)
    {
        return a <= (double)b;
    }

    public static boolean operator_greaterThan(double a, float b)
    {
        return a > (double)b;
    }

    public static boolean operator_greaterEqualsThan(double a, float b)
    {
        return a >= (double)b;
    }

    public static boolean operator_equals(double a, float b)
    {
        return a == (double)b;
    }

    public static boolean operator_notEquals(double a, float b)
    {
        return a != (double)b;
    }

    public static double operator_power(double a, float b)
    {
        return Math.pow(a, b);
    }

    public static boolean operator_tripleEquals(double a, float b)
    {
        return a == (double)b;
    }

    public static boolean operator_tripleNotEquals(double a, float b)
    {
        return a != (double)b;
    }

    public static double operator_plus(double a, long b)
    {
        return a + (double)b;
    }

    public static double operator_minus(double a, long b)
    {
        return a - (double)b;
    }

    public static double operator_multiply(double a, long b)
    {
        return a * (double)b;
    }

    public static double operator_divide(double a, long b)
    {
        return a / (double)b;
    }

    public static double operator_modulo(double a, long b)
    {
        return a % (double)b;
    }

    public static boolean operator_lessThan(double a, long b)
    {
        return a < (double)b;
    }

    public static boolean operator_lessEqualsThan(double a, long b)
    {
        return a <= (double)b;
    }

    public static boolean operator_greaterThan(double a, long b)
    {
        return a > (double)b;
    }

    public static boolean operator_greaterEqualsThan(double a, long b)
    {
        return a >= (double)b;
    }

    public static boolean operator_equals(double a, long b)
    {
        return a == (double)b;
    }

    public static boolean operator_notEquals(double a, long b)
    {
        return a != (double)b;
    }

    public static double operator_power(double a, long b)
    {
        return Math.pow(a, b);
    }

    public static boolean operator_tripleEquals(double a, long b)
    {
        return a == (double)b;
    }

    public static boolean operator_tripleNotEquals(double a, long b)
    {
        return a != (double)b;
    }

    public static double operator_plus(double a, int b)
    {
        return a + (double)b;
    }

    public static double operator_minus(double a, int b)
    {
        return a - (double)b;
    }

    public static double operator_multiply(double a, int b)
    {
        return a * (double)b;
    }

    public static double operator_divide(double a, int b)
    {
        return a / (double)b;
    }

    public static double operator_modulo(double a, int b)
    {
        return a % (double)b;
    }

    public static boolean operator_lessThan(double a, int b)
    {
        return a < (double)b;
    }

    public static boolean operator_lessEqualsThan(double a, int b)
    {
        return a <= (double)b;
    }

    public static boolean operator_greaterThan(double a, int b)
    {
        return a > (double)b;
    }

    public static boolean operator_greaterEqualsThan(double a, int b)
    {
        return a >= (double)b;
    }

    public static boolean operator_equals(double a, int b)
    {
        return a == (double)b;
    }

    public static boolean operator_notEquals(double a, int b)
    {
        return a != (double)b;
    }

    public static double operator_power(double a, int b)
    {
        return Math.pow(a, b);
    }

    public static boolean operator_tripleEquals(double a, int b)
    {
        return a == (double)b;
    }

    public static boolean operator_tripleNotEquals(double a, int b)
    {
        return a != (double)b;
    }

    public static double operator_plus(double a, char b)
    {
        return a + (double)b;
    }

    public static double operator_minus(double a, char b)
    {
        return a - (double)b;
    }

    public static double operator_multiply(double a, char b)
    {
        return a * (double)b;
    }

    public static double operator_divide(double a, char b)
    {
        return a / (double)b;
    }

    public static double operator_modulo(double a, char b)
    {
        return a % (double)b;
    }

    public static boolean operator_lessThan(double a, char b)
    {
        return a < (double)b;
    }

    public static boolean operator_lessEqualsThan(double a, char b)
    {
        return a <= (double)b;
    }

    public static boolean operator_greaterThan(double a, char b)
    {
        return a > (double)b;
    }

    public static boolean operator_greaterEqualsThan(double a, char b)
    {
        return a >= (double)b;
    }

    public static boolean operator_equals(double a, char b)
    {
        return a == (double)b;
    }

    public static boolean operator_notEquals(double a, char b)
    {
        return a != (double)b;
    }

    public static double operator_power(double a, char b)
    {
        return Math.pow(a, b);
    }

    public static boolean operator_tripleEquals(double a, char b)
    {
        return a == (double)b;
    }

    public static boolean operator_tripleNotEquals(double a, char b)
    {
        return a != (double)b;
    }

    public static double operator_plus(double a, short b)
    {
        return a + (double)b;
    }

    public static double operator_minus(double a, short b)
    {
        return a - (double)b;
    }

    public static double operator_multiply(double a, short b)
    {
        return a * (double)b;
    }

    public static double operator_divide(double a, short b)
    {
        return a / (double)b;
    }

    public static double operator_modulo(double a, short b)
    {
        return a % (double)b;
    }

    public static boolean operator_lessThan(double a, short b)
    {
        return a < (double)b;
    }

    public static boolean operator_lessEqualsThan(double a, short b)
    {
        return a <= (double)b;
    }

    public static boolean operator_greaterThan(double a, short b)
    {
        return a > (double)b;
    }

    public static boolean operator_greaterEqualsThan(double a, short b)
    {
        return a >= (double)b;
    }

    public static boolean operator_equals(double a, short b)
    {
        return a == (double)b;
    }

    public static boolean operator_notEquals(double a, short b)
    {
        return a != (double)b;
    }

    public static double operator_power(double a, short b)
    {
        return Math.pow(a, b);
    }

    public static boolean operator_tripleEquals(double a, short b)
    {
        return a == (double)b;
    }

    public static boolean operator_tripleNotEquals(double a, short b)
    {
        return a != (double)b;
    }

    public static double operator_plus(double a, byte b)
    {
        return a + (double)b;
    }

    public static double operator_minus(double a, byte b)
    {
        return a - (double)b;
    }

    public static double operator_multiply(double a, byte b)
    {
        return a * (double)b;
    }

    public static double operator_divide(double a, byte b)
    {
        return a / (double)b;
    }

    public static double operator_modulo(double a, byte b)
    {
        return a % (double)b;
    }

    public static boolean operator_lessThan(double a, byte b)
    {
        return a < (double)b;
    }

    public static boolean operator_lessEqualsThan(double a, byte b)
    {
        return a <= (double)b;
    }

    public static boolean operator_greaterThan(double a, byte b)
    {
        return a > (double)b;
    }

    public static boolean operator_greaterEqualsThan(double a, byte b)
    {
        return a >= (double)b;
    }

    public static boolean operator_equals(double a, byte b)
    {
        return a == (double)b;
    }

    public static boolean operator_notEquals(double a, byte b)
    {
        return a != (double)b;
    }

    public static double operator_power(double a, byte b)
    {
        return Math.pow(a, b);
    }

    public static boolean operator_tripleEquals(double a, byte b)
    {
        return a == (double)b;
    }

    public static boolean operator_tripleNotEquals(double a, byte b)
    {
        return a != (double)b;
    }
}
