// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   StringExtensions.java

package org.eclipse.xtext.xbase.lib;


public class StringExtensions
{

    public StringExtensions()
    {
    }

    public static String operator_plus(String a, Object b)
    {
        return (new StringBuilder()).append(a).append(b).toString();
    }

    public static String operator_plus(String a, String b)
    {
        return (new StringBuilder()).append(a).append(b).toString();
    }

    public static boolean isNullOrEmpty(String s)
    {
        return s == null || s.length() == 0;
    }

    public static String toFirstUpper(String s)
    {
        if(s == null || s.length() == 0)
            return s;
        if(Character.isUpperCase(s.charAt(0)))
            return s;
        if(s.length() == 1)
            return s.toUpperCase();
        else
            return (new StringBuilder()).append(s.substring(0, 1).toUpperCase()).append(s.substring(1)).toString();
    }

    public static String toFirstLower(String s)
    {
        if(s == null || s.length() == 0)
            return s;
        if(Character.isLowerCase(s.charAt(0)))
            return s;
        if(s.length() == 1)
            return s.toLowerCase();
        else
            return (new StringBuilder()).append(s.substring(0, 1).toLowerCase()).append(s.substring(1)).toString();
    }
}
