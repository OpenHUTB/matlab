// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   BigIntegerExtensions.java

package org.eclipse.xtext.xbase.lib;

import java.math.BigInteger;

public class BigIntegerExtensions
{

    public BigIntegerExtensions()
    {
    }

    public static BigInteger operator_minus(BigInteger a)
    {
        return a.negate();
    }

    public static BigInteger operator_plus(BigInteger a, BigInteger b)
    {
        return a.add(b);
    }

    public static BigInteger operator_minus(BigInteger a, BigInteger b)
    {
        return a.subtract(b);
    }

    public static BigInteger operator_power(BigInteger a, int exponent)
    {
        return a.pow(exponent);
    }

    public static BigInteger operator_multiply(BigInteger a, BigInteger b)
    {
        return a.multiply(b);
    }

    public static BigInteger operator_divide(BigInteger a, BigInteger b)
    {
        return a.divide(b);
    }

    public static BigInteger operator_modulo(BigInteger a, BigInteger b)
    {
        return a.mod(b);
    }
}
