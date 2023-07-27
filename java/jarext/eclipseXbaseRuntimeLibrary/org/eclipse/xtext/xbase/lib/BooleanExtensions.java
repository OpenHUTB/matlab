// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   BooleanExtensions.java

package org.eclipse.xtext.xbase.lib;

import com.google.common.primitives.Booleans;

public class BooleanExtensions
{

    public BooleanExtensions()
    {
    }

    public static boolean operator_and(boolean a, boolean b)
    {
        return a && b;
    }

    public static boolean operator_or(boolean a, boolean b)
    {
        return a || b;
    }

    public static boolean operator_not(boolean b)
    {
        return !b;
    }

    public static boolean operator_equals(boolean a, boolean b)
    {
        return a == b;
    }

    public static boolean operator_notEquals(boolean a, boolean b)
    {
        return a != b;
    }

    public static boolean xor(boolean a, boolean b)
    {
        return a ^ b;
    }

    public static boolean operator_lessThan(boolean a, boolean b)
    {
        return Booleans.compare(a, b) < 0;
    }

    public static boolean operator_lessEqualsThan(boolean a, boolean b)
    {
        return Booleans.compare(a, b) <= 0;
    }

    public static boolean operator_greaterThan(boolean a, boolean b)
    {
        return Booleans.compare(a, b) > 0;
    }

    public static boolean operator_greaterEqualsThan(boolean a, boolean b)
    {
        return Booleans.compare(a, b) >= 0;
    }
}
