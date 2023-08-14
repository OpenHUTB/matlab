// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   Exceptions.java

package org.eclipse.xtext.xbase.lib;


public class Exceptions
{

    public Exceptions()
    {
    }

    public static RuntimeException sneakyThrow(Throwable t)
    {
        if(t == null)
        {
            throw new NullPointerException("t");
        } else
        {
            sneakyThrow0(t);
            return null;
        }
    }

    private static void sneakyThrow0(Throwable t)
        throws Throwable
    {
        throw t;
    }
}
