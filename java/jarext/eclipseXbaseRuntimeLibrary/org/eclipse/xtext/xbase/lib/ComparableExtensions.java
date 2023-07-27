// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   ComparableExtensions.java

package org.eclipse.xtext.xbase.lib;


public class ComparableExtensions
{

    public ComparableExtensions()
    {
    }

    public static boolean operator_lessThan(Comparable left, Object right)
    {
        return left.compareTo(right) < 0;
    }

    public static boolean operator_greaterThan(Comparable left, Object right)
    {
        return left.compareTo(right) > 0;
    }

    public static boolean operator_lessEqualsThan(Comparable left, Object right)
    {
        return left.compareTo(right) <= 0;
    }

    public static boolean operator_greaterEqualsThan(Comparable left, Object right)
    {
        return left.compareTo(right) >= 0;
    }

    public static int operator_spaceship(Comparable left, Object right)
    {
        return left.compareTo(right);
    }
}
