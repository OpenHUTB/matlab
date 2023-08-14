// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   DefaultLineDelimiter.java

package org.eclipse.xtend2.lib;


class DefaultLineDelimiter
{

    DefaultLineDelimiter()
    {
    }

    public static String get()
    {
        return System.getProperty("line.separator");
    }
}
