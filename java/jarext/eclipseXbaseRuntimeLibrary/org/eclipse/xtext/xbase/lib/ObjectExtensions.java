// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   ObjectExtensions.java

package org.eclipse.xtext.xbase.lib;

import com.google.common.base.Objects;

// Referenced classes of package org.eclipse.xtext.xbase.lib:
//            Pair, Procedures

public class ObjectExtensions
{

    public ObjectExtensions()
    {
    }

    public static boolean operator_notEquals(Object a, Object b)
    {
        return !Objects.equal(a, b);
    }

    public static boolean operator_equals(Object a, Object b)
    {
        return Objects.equal(a, b);
    }

    public static boolean identityEquals(Object a, Object b)
    {
        return a == b;
    }

    public static boolean operator_tripleEquals(Object a, Object b)
    {
        return a == b;
    }

    public static boolean operator_tripleNotEquals(Object a, Object b)
    {
        return a != b;
    }

    public static Pair operator_mappedTo(Object a, Object b)
    {
        return Pair.of(a, b);
    }

    public static Object operator_doubleArrow(Object object, Procedures.Procedure1 block)
    {
        block.apply(object);
        return object;
    }

    public static String operator_plus(Object a, String b)
    {
        return (new StringBuilder()).append(a).append(b).toString();
    }

    public static Object operator_elvis(Object first, Object second)
    {
        if(first != null)
            return first;
        else
            return second;
    }
}
