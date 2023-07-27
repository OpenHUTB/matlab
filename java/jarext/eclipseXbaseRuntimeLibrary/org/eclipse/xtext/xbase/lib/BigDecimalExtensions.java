// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   BigDecimalExtensions.java

package org.eclipse.xtext.xbase.lib;

import java.math.BigDecimal;
import java.math.MathContext;

public class BigDecimalExtensions
{

    public BigDecimalExtensions()
    {
    }

    public static BigDecimal operator_minus(BigDecimal a)
    {
        return a.negate();
    }

    public static BigDecimal operator_plus(BigDecimal a, BigDecimal b)
    {
        return a.add(b);
    }

    public static BigDecimal operator_minus(BigDecimal a, BigDecimal b)
    {
        return a.subtract(b);
    }

    public static BigDecimal operator_power(BigDecimal a, int exponent)
    {
        return a.pow(exponent);
    }

    public static BigDecimal operator_multiply(BigDecimal a, BigDecimal b)
    {
        return a.multiply(b);
    }

    public static BigDecimal operator_divide(BigDecimal a, BigDecimal b)
    {
        return a.divide(b, MathContext.DECIMAL128);
    }
}
