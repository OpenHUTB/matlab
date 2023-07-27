// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   CharacterExtensions.java

package org.eclipse.xtext.xbase.lib;


// Referenced classes of package org.eclipse.xtext.xbase.lib:
//            HardcodedInInterpreterException

public class CharacterExtensions
{

    public CharacterExtensions()
    {
    }

    public static int operator_minus(char c)
    {
        return -c;
    }

    public static char operator_minusMinus(char c)
    {
        throw new HardcodedInInterpreterException();
    }

    public static Character operator_minusMinus(Character c)
    {
        throw new HardcodedInInterpreterException();
    }

    public static char operator_plusPlus(char c)
    {
        throw new HardcodedInInterpreterException();
    }

    public static Character operator_plusPlus(Character c)
    {
        throw new HardcodedInInterpreterException();
    }

    public static double operator_plus(char a, double b)
    {
        return (double)a + b;
    }

    public static double operator_minus(char a, double b)
    {
        return (double)a - b;
    }

    public static double operator_multiply(char a, double b)
    {
        return (double)a * b;
    }

    public static double operator_divide(char a, double b)
    {
        return (double)a / b;
    }

    public static double operator_modulo(char a, double b)
    {
        return (double)a % b;
    }

    public static boolean operator_lessThan(char a, double b)
    {
        return (double)a < b;
    }

    public static boolean operator_lessEqualsThan(char a, double b)
    {
        return (double)a <= b;
    }

    public static boolean operator_greaterThan(char a, double b)
    {
        return (double)a > b;
    }

    public static boolean operator_greaterEqualsThan(char a, double b)
    {
        return (double)a >= b;
    }

    public static boolean operator_equals(char a, double b)
    {
        return (double)a == b;
    }

    public static boolean operator_notEquals(char a, double b)
    {
        return (double)a != b;
    }

    public static double operator_power(char a, double b)
    {
        return Math.pow(a, b);
    }

    public static boolean operator_tripleEquals(char a, double b)
    {
        return (double)a == b;
    }

    public static boolean operator_tripleNotEquals(char a, double b)
    {
        return (double)a != b;
    }

    public static float operator_plus(char a, float b)
    {
        return (float)a + b;
    }

    public static float operator_minus(char a, float b)
    {
        return (float)a - b;
    }

    public static float operator_multiply(char a, float b)
    {
        return (float)a * b;
    }

    public static float operator_divide(char a, float b)
    {
        return (float)a / b;
    }

    public static float operator_modulo(char a, float b)
    {
        return (float)a % b;
    }

    public static boolean operator_lessThan(char a, float b)
    {
        return (float)a < b;
    }

    public static boolean operator_lessEqualsThan(char a, float b)
    {
        return (float)a <= b;
    }

    public static boolean operator_greaterThan(char a, float b)
    {
        return (float)a > b;
    }

    public static boolean operator_greaterEqualsThan(char a, float b)
    {
        return (float)a >= b;
    }

    public static boolean operator_equals(char a, float b)
    {
        return (float)a == b;
    }

    public static boolean operator_notEquals(char a, float b)
    {
        return (float)a != b;
    }

    public static double operator_power(char a, float b)
    {
        return Math.pow(a, b);
    }

    public static boolean operator_tripleEquals(char a, float b)
    {
        return (float)a == b;
    }

    public static boolean operator_tripleNotEquals(char a, float b)
    {
        return (float)a != b;
    }

    public static long operator_plus(char a, long b)
    {
        return (long)a + b;
    }

    public static long operator_minus(char a, long b)
    {
        return (long)a - b;
    }

    public static long operator_multiply(char a, long b)
    {
        return (long)a * b;
    }

    public static long operator_divide(char a, long b)
    {
        return (long)a / b;
    }

    public static long operator_modulo(char a, long b)
    {
        return (long)a % b;
    }

    public static boolean operator_lessThan(char a, long b)
    {
        return (long)a < b;
    }

    public static boolean operator_lessEqualsThan(char a, long b)
    {
        return (long)a <= b;
    }

    public static boolean operator_greaterThan(char a, long b)
    {
        return (long)a > b;
    }

    public static boolean operator_greaterEqualsThan(char a, long b)
    {
        return (long)a >= b;
    }

    public static boolean operator_equals(char a, long b)
    {
        return (long)a == b;
    }

    public static boolean operator_notEquals(char a, long b)
    {
        return (long)a != b;
    }

    public static double operator_power(char a, long b)
    {
        return Math.pow(a, b);
    }

    public static boolean operator_tripleEquals(char a, long b)
    {
        return (long)a == b;
    }

    public static boolean operator_tripleNotEquals(char a, long b)
    {
        return (long)a != b;
    }

    public static int operator_plus(char a, int b)
    {
        return a + b;
    }

    public static int operator_minus(char a, int b)
    {
        return a - b;
    }

    public static int operator_multiply(char a, int b)
    {
        return a * b;
    }

    public static int operator_divide(char a, int b)
    {
        return a / b;
    }

    public static int operator_modulo(char a, int b)
    {
        return a % b;
    }

    public static boolean operator_lessThan(char a, int b)
    {
        return a < b;
    }

    public static boolean operator_lessEqualsThan(char a, int b)
    {
        return a <= b;
    }

    public static boolean operator_greaterThan(char a, int b)
    {
        return a > b;
    }

    public static boolean operator_greaterEqualsThan(char a, int b)
    {
        return a >= b;
    }

    public static boolean operator_equals(char a, int b)
    {
        return a == b;
    }

    public static boolean operator_notEquals(char a, int b)
    {
        return a != b;
    }

    public static double operator_power(char a, int b)
    {
        return Math.pow(a, b);
    }

    public static boolean operator_tripleEquals(char a, int b)
    {
        return a == b;
    }

    public static boolean operator_tripleNotEquals(char a, int b)
    {
        return a != b;
    }

    public static int operator_plus(char a, char b)
    {
        return a + b;
    }

    public static int operator_minus(char a, char b)
    {
        return a - b;
    }

    public static int operator_multiply(char a, char b)
    {
        return a * b;
    }

    public static int operator_divide(char a, char b)
    {
        return a / b;
    }

    public static int operator_modulo(char a, char b)
    {
        return a % b;
    }

    public static boolean operator_lessThan(char a, char b)
    {
        return a < b;
    }

    public static boolean operator_lessEqualsThan(char a, char b)
    {
        return a <= b;
    }

    public static boolean operator_greaterThan(char a, char b)
    {
        return a > b;
    }

    public static boolean operator_greaterEqualsThan(char a, char b)
    {
        return a >= b;
    }

    public static boolean operator_equals(char a, char b)
    {
        return a == b;
    }

    public static boolean operator_notEquals(char a, char b)
    {
        return a != b;
    }

    public static double operator_power(char a, char b)
    {
        return Math.pow(a, b);
    }

    public static boolean operator_tripleEquals(char a, char b)
    {
        return a == b;
    }

    public static boolean operator_tripleNotEquals(char a, char b)
    {
        return a != b;
    }

    public static int operator_plus(char a, short b)
    {
        return a + b;
    }

    public static int operator_minus(char a, short b)
    {
        return a - b;
    }

    public static int operator_multiply(char a, short b)
    {
        return a * b;
    }

    public static int operator_divide(char a, short b)
    {
        return a / b;
    }

    public static int operator_modulo(char a, short b)
    {
        return a % b;
    }

    public static boolean operator_lessThan(char a, short b)
    {
        return a < b;
    }

    public static boolean operator_lessEqualsThan(char a, short b)
    {
        return a <= b;
    }

    public static boolean operator_greaterThan(char a, short b)
    {
        return a > b;
    }

    public static boolean operator_greaterEqualsThan(char a, short b)
    {
        return a >= b;
    }

    public static boolean operator_equals(char a, short b)
    {
        return a == b;
    }

    public static boolean operator_notEquals(char a, short b)
    {
        return a != b;
    }

    public static double operator_power(char a, short b)
    {
        return Math.pow(a, b);
    }

    public static boolean operator_tripleEquals(char a, short b)
    {
        return a == b;
    }

    public static boolean operator_tripleNotEquals(char a, short b)
    {
        return a != b;
    }

    public static int operator_plus(char a, byte b)
    {
        return a + b;
    }

    public static int operator_minus(char a, byte b)
    {
        return a - b;
    }

    public static int operator_multiply(char a, byte b)
    {
        return a * b;
    }

    public static int operator_divide(char a, byte b)
    {
        return a / b;
    }

    public static int operator_modulo(char a, byte b)
    {
        return a % b;
    }

    public static boolean operator_lessThan(char a, byte b)
    {
        return a < b;
    }

    public static boolean operator_lessEqualsThan(char a, byte b)
    {
        return a <= b;
    }

    public static boolean operator_greaterThan(char a, byte b)
    {
        return a > b;
    }

    public static boolean operator_greaterEqualsThan(char a, byte b)
    {
        return a >= b;
    }

    public static boolean operator_equals(char a, byte b)
    {
        return a == b;
    }

    public static boolean operator_notEquals(char a, byte b)
    {
        return a != b;
    }

    public static double operator_power(char a, byte b)
    {
        return Math.pow(a, b);
    }

    public static boolean operator_tripleEquals(char a, byte b)
    {
        return a == b;
    }

    public static boolean operator_tripleNotEquals(char a, byte b)
    {
        return a != b;
    }
}
