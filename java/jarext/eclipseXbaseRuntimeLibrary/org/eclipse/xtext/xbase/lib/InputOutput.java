// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   InputOutput.java

package org.eclipse.xtext.xbase.lib;

import java.io.PrintStream;

public class InputOutput
{

    public InputOutput()
    {
    }

    public static void println()
    {
        System.out.println();
    }

    public static Object println(Object object)
    {
        System.out.println(object);
        return object;
    }

    public static Object print(Object o)
    {
        System.out.print(o);
        return o;
    }
}
