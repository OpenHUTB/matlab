// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   MLPrefsDialog.java

package com.mathworks.mlservices;


public interface MLPrefsDialog
{

    public abstract void showPrefsDialog();

    public abstract void showPrefsDialog(String s);

    public abstract void showLastPrefsDialog(String s);

    public abstract void registerPanel(String s, String s1, boolean flag)
        throws ClassNotFoundException;

    public abstract void unregisterPanel(String s, String s1);
}
