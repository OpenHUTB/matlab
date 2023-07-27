// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   IntegerExtensions.java

package org.eclipse.xtext.xbase.lib;


// Referenced classes of package org.eclipse.xtext.xbase.lib:
//            IntegerRange, ExclusiveRange, HardcodedInInterpreterException

public class IntegerExtensions
{

    public IntegerExtensions()
    {
    }

    public static IntegerRange operator_upTo(int a, int b)
    {
        return new IntegerRange(a, b);
    }

    public static ExclusiveRange operator_doubleDotLessThan(int a, int b)
    {
        return new ExclusiveRange(a, b, true);
    }

    public static ExclusiveRange operator_greaterThanDoubleDot(int a, int b)
    {
        return new ExclusiveRange(a, b, false);
    }

    public static int bitwiseOr(int a, int b)
    {
        return a | b;
    }

    public static int bitwiseXor(int a, int b)
    {
        return a ^ b;
    }

    public static int bitwiseAnd(int a, int b)
    {
        return a & b;
    }

    public static int bitwiseNot(int a)
    {
        return ~a;
    }

    /**
     * @deprecated Method shiftLeft is deprecated
     */

    public static int shiftLeft(int a, int distance)
    {
        return a << distance;
    }

    public static int operator_doubleLessThan(int a, int distance)
    {
        return a << distance;
    }

    /**
     * @deprecated Method shiftRight is deprecated
     */

    public static int shiftRight(int a, int distance)
    {
        return a >> distance;
    }

    public static int operator_doubleGreaterThan(int a, int distance)
    {
        return a >> distance;
    }

    /**
     * @deprecated Method shiftRightUnsigned is deprecated
     */

    public static int shiftRightUnsigned(int a, int distance)
    {
        return a >>> distance;
    }

    public static int operator_tripleGreaterThan(int a, int distance)
    {
        return a >>> distance;
    }

    public static int operator_minus(int i)
    {
        return -i;
    }

    public static int operator_minusMinus(int i)
    {
        throw new HardcodedInInterpreterException();
    }

    public static Integer operator_minusMinus(Integer i)
    {
        throw new HardcodedInInterpreterException();
    }

    public static int operator_plusPlus(int i)
    {
        throw new HardcodedInInterpreterException();
    }

    public static Integer operator_plusPlus(Integer i)
    {
        throw new HardcodedInInterpreterException();
    }

    public static double operator_plus(int a, double b)
    {
        return (double)a + b;
    }

    public static double operator_minus(int a, double b)
    {
        return (double)a - b;
    }

    public static double operator_multiply(int a, double b)
    {
        return (double)a * b;
    }

    public static double operator_divide(int a, double b)
    {
        return (double)a / b;
    }

    public static double operator_modulo(int a, double b)
    {
        return (double)a % b;
    }

    public static boolean operator_lessThan(int a, double b)
    {
        return (double)a < b;
    }

    public static boolean operator_lessEqualsThan(int a, double b)
    {
        return (double)a <= b;
    }

    public static boolean operator_greaterThan(int a, double b)
    {
        return (double)a > b;
    }

    public static boolean operator_greaterEqualsThan(int a, double b)
    {
        return (double)a >= b;
    }

    public static boolean operator_equals(int a, double b)
    {
        return (double)a == b;
    }

    public static boolean operator_notEquals(int a, double b)
    {
        return (double)a != b;
    }

    public static double operator_power(int a, double b)
    {
        return Math.pow(a, b);
    }

    public static boolean operator_tripleEquals(int a, double b)
    {
        return (double)a == b;
    }

    public static boolean operator_tripleNotEquals(int a, double b)
    {
        return (double)a != b;
    }

    public static float operator_plus(int a, float b)
    {
        return (float)a + b;
    }

    public static float operator_minus(int a, float b)
    {
        return (float)a - b;
    }

    public static float operator_multiply(int a, float b)
    {
        return (float)a * b;
    }

    public static float operator_divide(int a, float b)
    {
        return (float)a / b;
    }

    public static float operator_modulo(int a, float b)
    {
        return (float)a % b;
    }

    public static boolean operator_lessThan(int a, float b)
    {
        return (float)a < b;
    }

    public static boolean operator_lessEqualsThan(int a, float b)
    {
        return (float)a <= b;
    }

    public static boolean operator_greaterThan(int a, float b)
    {
        return (float)a > b;
    }

    public static boolean operator_greaterEqualsThan(int a, float b)
    {
        return (float)a >= b;
    }

    public static boolean operator_equals(int a, float b)
    {
        return (float)a == b;
    }

    public static boolean operator_notEquals(int a, float b)
    {
        return (float)a != b;
    }

    public static double operator_power(int a, float b)
    {
        return Math.pow(a, b);
    }

    public static boolean operator_tripleEquals(int a, float b)
    {
        return (float)a == b;
    }

    public static boolean operator_tripleNotEquals(int a, float b)
    {
        return (float)a != b;
    }

    public static long operator_plus(int a, long b)
    {
        return (long)a + b;
    }

    public static long operator_minus(int a, long b)
    {
        return (long)a - b;
    }

    public static long operator_multiply(int a, long b)
    {
        return (long)a * b;
    }

    public static long operator_divide(int a, long b)
    {
        return (long)a / b;
    }

    public static long operator_modulo(int a, long b)
    {
        return (long)a % b;
    }

    public static boolean operator_lessThan(int a, long b)
    {
        return (long)a < b;
    }

    public static boolean operator_lessEqualsThan(int a, long b)
    {
        return (long)a <= b;
    }

    public static boolean operator_greaterThan(int a, long b)
    {
        return (long)a > b;
    }

    public static boolean operator_greaterEqualsThan(int a, long b)
    {
        return (long)a >= b;
    }

    public static boolean operator_equals(int a, long b)
    {
        return (long)a == b;
    }

    public static boolean operator_notEquals(int a, long b)
    {
        return (long)a != b;
    }

    public static double operator_power(int a, long b)
    {
        return Math.pow(a, b);
    }

    public static boolean operator_tripleEquals(int a, long b)
    {
        return (long)a == b;
    }

    public static boolean operator_tripleNotEquals(int a, long b)
    {
        return (long)a != b;
    }

    public static int operator_plus(int a, int b)
    {
        return a + b;
    }

    public static int operator_minus(int a, int b)
    {
        return a - b;
    }

    public static int operator_multiply(int a, int b)
    {
        return a * b;
    }

    public static int operator_divide(int a, int b)
    {
        return a / b;
    }

    public static int operator_modulo(int a, int b)
    {
        return a % b;
    }

    public static boolean operator_lessThan(int a, int b)
    {
        return a < b;
    }

    public static boolean operator_lessEqualsThan(int a, int b)
    {
        return a <= b;
    }

    public static boolean operator_greaterThan(int a, int b)
    {
        return a > b;
    }

    public static boolean operator_greaterEqualsThan(int a, int b)
    {
        return a >= b;
    }

    public static boolean operator_equals(int a, int b)
    {
        return a == b;
    }

    public static boolean operator_notEquals(int a, int b)
    {
        return a != b;
    }

    public static double operator_power(int a, int b)
    {
        return Math.pow(a, b);
    }

    public static boolean operator_tripleEquals(int a, int b)
    {
        return a == b;
    }

    public static boolean operator_tripleNotEquals(int a, int b)
    {
        return a != b;
    }

    public static int operator_plus(int a, char b)
    {
        return a + b;
    }

    public static int operator_minus(int a, char b)
    {
        return a - b;
    }

    public static int operator_multiply(int a, char b)
    {
        return a * b;
    }

    public static int operator_divide(int a, char b)
    {
        return a / b;
    }

    public static int operator_modulo(int a, char b)
    {
        return a % b;
    }

    public static boolean operator_lessThan(int a, char b)
    {
        return a < b;
    }

    public static boolean operator_lessEqualsThan(int a, char b)
    {
        return a <= b;
    }

    public static boolean operator_greaterThan(int a, char b)
    {
        return a > b;
    }

    public static boolean operator_greaterEqualsThan(int a, char b)
    {
        return a >= b;
    }

    public static boolean operator_equals(int a, char b)
    {
        return a == b;
    }

    public static boolean operator_notEquals(int a, char b)
    {
        return a != b;
    }

    public static double operator_power(int a, char b)
    {
        return Math.pow(a, b);
    }

    public static boolean operator_tripleEquals(int a, char b)
    {
        return a == b;
    }

    public static boolean operator_tripleNotEquals(int a, char b)
    {
        return a != b;
    }

    public static int operator_plus(int a, short b)
    {
        return a + b;
    }

    public static int operator_minus(int a, short b)
    {
        return a - b;
    }

    public static int operator_multiply(int a, short b)
    {
        return a * b;
    }

    public static int operator_divide(int a, short b)
    {
        return a / b;
    }

    public static int operator_modulo(int a, short b)
    {
        return a % b;
    }

    public static boolean operator_lessThan(int a, short b)
    {
        return a < b;
    }

    public static boolean operator_lessEqualsThan(int a, short b)
    {
        return a <= b;
    }

    public static boolean operator_greaterThan(int a, short b)
    {
        return a > b;
    }

    public static boolean operator_greaterEqualsThan(int a, short b)
    {
        return a >= b;
    }

    public static boolean operator_equals(int a, short b)
    {
        return a == b;
    }

    public static boolean operator_notEquals(int a, short b)
    {
        return a != b;
    }

    public static double operator_power(int a, short b)
    {
        return Math.pow(a, b);
    }

    public static boolean operator_tripleEquals(int a, short b)
    {
        return a == b;
    }

    public static boolean operator_tripleNotEquals(int a, short b)
    {
        return a != b;
    }

    public static int operator_plus(int a, byte b)
    {
        return a + b;
    }

    public static int operator_minus(int a, byte b)
    {
        return a - b;
    }

    public static int operator_multiply(int a, byte b)
    {
        return a * b;
    }

    public static int operator_divide(int a, byte b)
    {
        return a / b;
    }

    public static int operator_modulo(int a, byte b)
    {
        return a % b;
    }

    public static boolean operator_lessThan(int a, byte b)
    {
        return a < b;
    }

    public static boolean operator_lessEqualsThan(int a, byte b)
    {
        return a <= b;
    }

    public static boolean operator_greaterThan(int a, byte b)
    {
        return a > b;
    }

    public static boolean operator_greaterEqualsThan(int a, byte b)
    {
        return a >= b;
    }

    public static boolean operator_equals(int a, byte b)
    {
        return a == b;
    }

    public static boolean operator_notEquals(int a, byte b)
    {
        return a != b;
    }

    public static double operator_power(int a, byte b)
    {
        return Math.pow(a, b);
    }

    public static boolean operator_tripleEquals(int a, byte b)
    {
        return a == b;
    }

    public static boolean operator_tripleNotEquals(int a, byte b)
    {
        return a != b;
    }
}
