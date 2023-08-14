// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   LongExtensions.java

package org.eclipse.xtext.xbase.lib;


// Referenced classes of package org.eclipse.xtext.xbase.lib:
//            HardcodedInInterpreterException

public class LongExtensions
{

    public LongExtensions()
    {
    }

    public static long bitwiseOr(long a, long b)
    {
        return a | b;
    }

    public static long bitwiseXor(long a, long b)
    {
        return a ^ b;
    }

    public static long bitwiseAnd(long a, long b)
    {
        return a & b;
    }

    public static long bitwiseNot(long a)
    {
        return ~a;
    }

    /**
     * @deprecated Method shiftLeft is deprecated
     */

    public static long shiftLeft(long a, int distance)
    {
        return a << distance;
    }

    public static long operator_doubleLessThan(long a, int distance)
    {
        return a << distance;
    }

    /**
     * @deprecated Method shiftRight is deprecated
     */

    public static long shiftRight(long a, int distance)
    {
        return a >> distance;
    }

    public static long operator_doubleGreaterThan(long a, int distance)
    {
        return a >> distance;
    }

    /**
     * @deprecated Method shiftRightUnsigned is deprecated
     */

    public static long shiftRightUnsigned(long a, int distance)
    {
        return a >>> distance;
    }

    public static long operator_tripleGreaterThan(long a, int distance)
    {
        return a >>> distance;
    }

    public static long operator_minus(long l)
    {
        return -l;
    }

    public static long operator_minusMinus(long l)
    {
        throw new HardcodedInInterpreterException();
    }

    public static Long operator_minusMinus(Long l)
    {
        throw new HardcodedInInterpreterException();
    }

    public static long operator_plusPlus(long l)
    {
        throw new HardcodedInInterpreterException();
    }

    public static Long operator_plusPlus(Long l)
    {
        throw new HardcodedInInterpreterException();
    }

    public static double operator_plus(long a, double b)
    {
        return (double)a + b;
    }

    public static double operator_minus(long a, double b)
    {
        return (double)a - b;
    }

    public static double operator_multiply(long a, double b)
    {
        return (double)a * b;
    }

    public static double operator_divide(long a, double b)
    {
        return (double)a / b;
    }

    public static double operator_modulo(long a, double b)
    {
        return (double)a % b;
    }

    public static boolean operator_lessThan(long a, double b)
    {
        return (double)a < b;
    }

    public static boolean operator_lessEqualsThan(long a, double b)
    {
        return (double)a <= b;
    }

    public static boolean operator_greaterThan(long a, double b)
    {
        return (double)a > b;
    }

    public static boolean operator_greaterEqualsThan(long a, double b)
    {
        return (double)a >= b;
    }

    public static boolean operator_equals(long a, double b)
    {
        return (double)a == b;
    }

    public static boolean operator_notEquals(long a, double b)
    {
        return (double)a != b;
    }

    public static double operator_power(long a, double b)
    {
        return Math.pow(a, b);
    }

    public static boolean operator_tripleEquals(long a, double b)
    {
        return (double)a == b;
    }

    public static boolean operator_tripleNotEquals(long a, double b)
    {
        return (double)a != b;
    }

    public static float operator_plus(long a, float b)
    {
        return (float)a + b;
    }

    public static float operator_minus(long a, float b)
    {
        return (float)a - b;
    }

    public static float operator_multiply(long a, float b)
    {
        return (float)a * b;
    }

    public static float operator_divide(long a, float b)
    {
        return (float)a / b;
    }

    public static float operator_modulo(long a, float b)
    {
        return (float)a % b;
    }

    public static boolean operator_lessThan(long a, float b)
    {
        return (float)a < b;
    }

    public static boolean operator_lessEqualsThan(long a, float b)
    {
        return (float)a <= b;
    }

    public static boolean operator_greaterThan(long a, float b)
    {
        return (float)a > b;
    }

    public static boolean operator_greaterEqualsThan(long a, float b)
    {
        return (float)a >= b;
    }

    public static boolean operator_equals(long a, float b)
    {
        return (float)a == b;
    }

    public static boolean operator_notEquals(long a, float b)
    {
        return (float)a != b;
    }

    public static double operator_power(long a, float b)
    {
        return Math.pow(a, b);
    }

    public static boolean operator_tripleEquals(long a, float b)
    {
        return (float)a == b;
    }

    public static boolean operator_tripleNotEquals(long a, float b)
    {
        return (float)a != b;
    }

    public static long operator_plus(long a, long b)
    {
        return a + b;
    }

    public static long operator_minus(long a, long b)
    {
        return a - b;
    }

    public static long operator_multiply(long a, long b)
    {
        return a * b;
    }

    public static long operator_divide(long a, long b)
    {
        return a / b;
    }

    public static long operator_modulo(long a, long b)
    {
        return a % b;
    }

    public static boolean operator_lessThan(long a, long b)
    {
        return a < b;
    }

    public static boolean operator_lessEqualsThan(long a, long b)
    {
        return a <= b;
    }

    public static boolean operator_greaterThan(long a, long b)
    {
        return a > b;
    }

    public static boolean operator_greaterEqualsThan(long a, long b)
    {
        return a >= b;
    }

    public static boolean operator_equals(long a, long b)
    {
        return a == b;
    }

    public static boolean operator_notEquals(long a, long b)
    {
        return a != b;
    }

    public static double operator_power(long a, long b)
    {
        return Math.pow(a, b);
    }

    public static boolean operator_tripleEquals(long a, long b)
    {
        return a == b;
    }

    public static boolean operator_tripleNotEquals(long a, long b)
    {
        return a != b;
    }

    public static long operator_plus(long a, int b)
    {
        return a + (long)b;
    }

    public static long operator_minus(long a, int b)
    {
        return a - (long)b;
    }

    public static long operator_multiply(long a, int b)
    {
        return a * (long)b;
    }

    public static long operator_divide(long a, int b)
    {
        return a / (long)b;
    }

    public static long operator_modulo(long a, int b)
    {
        return a % (long)b;
    }

    public static boolean operator_lessThan(long a, int b)
    {
        return a < (long)b;
    }

    public static boolean operator_lessEqualsThan(long a, int b)
    {
        return a <= (long)b;
    }

    public static boolean operator_greaterThan(long a, int b)
    {
        return a > (long)b;
    }

    public static boolean operator_greaterEqualsThan(long a, int b)
    {
        return a >= (long)b;
    }

    public static boolean operator_equals(long a, int b)
    {
        return a == (long)b;
    }

    public static boolean operator_notEquals(long a, int b)
    {
        return a != (long)b;
    }

    public static double operator_power(long a, int b)
    {
        return Math.pow(a, b);
    }

    public static boolean operator_tripleEquals(long a, int b)
    {
        return a == (long)b;
    }

    public static boolean operator_tripleNotEquals(long a, int b)
    {
        return a != (long)b;
    }

    public static long operator_plus(long a, char b)
    {
        return a + (long)b;
    }

    public static long operator_minus(long a, char b)
    {
        return a - (long)b;
    }

    public static long operator_multiply(long a, char b)
    {
        return a * (long)b;
    }

    public static long operator_divide(long a, char b)
    {
        return a / (long)b;
    }

    public static long operator_modulo(long a, char b)
    {
        return a % (long)b;
    }

    public static boolean operator_lessThan(long a, char b)
    {
        return a < (long)b;
    }

    public static boolean operator_lessEqualsThan(long a, char b)
    {
        return a <= (long)b;
    }

    public static boolean operator_greaterThan(long a, char b)
    {
        return a > (long)b;
    }

    public static boolean operator_greaterEqualsThan(long a, char b)
    {
        return a >= (long)b;
    }

    public static boolean operator_equals(long a, char b)
    {
        return a == (long)b;
    }

    public static boolean operator_notEquals(long a, char b)
    {
        return a != (long)b;
    }

    public static double operator_power(long a, char b)
    {
        return Math.pow(a, b);
    }

    public static boolean operator_tripleEquals(long a, char b)
    {
        return a == (long)b;
    }

    public static boolean operator_tripleNotEquals(long a, char b)
    {
        return a != (long)b;
    }

    public static long operator_plus(long a, short b)
    {
        return a + (long)b;
    }

    public static long operator_minus(long a, short b)
    {
        return a - (long)b;
    }

    public static long operator_multiply(long a, short b)
    {
        return a * (long)b;
    }

    public static long operator_divide(long a, short b)
    {
        return a / (long)b;
    }

    public static long operator_modulo(long a, short b)
    {
        return a % (long)b;
    }

    public static boolean operator_lessThan(long a, short b)
    {
        return a < (long)b;
    }

    public static boolean operator_lessEqualsThan(long a, short b)
    {
        return a <= (long)b;
    }

    public static boolean operator_greaterThan(long a, short b)
    {
        return a > (long)b;
    }

    public static boolean operator_greaterEqualsThan(long a, short b)
    {
        return a >= (long)b;
    }

    public static boolean operator_equals(long a, short b)
    {
        return a == (long)b;
    }

    public static boolean operator_notEquals(long a, short b)
    {
        return a != (long)b;
    }

    public static double operator_power(long a, short b)
    {
        return Math.pow(a, b);
    }

    public static boolean operator_tripleEquals(long a, short b)
    {
        return a == (long)b;
    }

    public static boolean operator_tripleNotEquals(long a, short b)
    {
        return a != (long)b;
    }

    public static long operator_plus(long a, byte b)
    {
        return a + (long)b;
    }

    public static long operator_minus(long a, byte b)
    {
        return a - (long)b;
    }

    public static long operator_multiply(long a, byte b)
    {
        return a * (long)b;
    }

    public static long operator_divide(long a, byte b)
    {
        return a / (long)b;
    }

    public static long operator_modulo(long a, byte b)
    {
        return a % (long)b;
    }

    public static boolean operator_lessThan(long a, byte b)
    {
        return a < (long)b;
    }

    public static boolean operator_lessEqualsThan(long a, byte b)
    {
        return a <= (long)b;
    }

    public static boolean operator_greaterThan(long a, byte b)
    {
        return a > (long)b;
    }

    public static boolean operator_greaterEqualsThan(long a, byte b)
    {
        return a >= (long)b;
    }

    public static boolean operator_equals(long a, byte b)
    {
        return a == (long)b;
    }

    public static boolean operator_notEquals(long a, byte b)
    {
        return a != (long)b;
    }

    public static double operator_power(long a, byte b)
    {
        return Math.pow(a, b);
    }

    public static boolean operator_tripleEquals(long a, byte b)
    {
        return a == (long)b;
    }

    public static boolean operator_tripleNotEquals(long a, byte b)
    {
        return a != (long)b;
    }
}
