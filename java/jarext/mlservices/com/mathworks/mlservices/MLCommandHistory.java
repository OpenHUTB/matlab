// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   MLCommandHistory.java

package com.mathworks.mlservices;


public interface MLCommandHistory
{

    public abstract String[] getAllHistory();

    public abstract String[] getSessionHistory();

    public abstract void removeAll();

    public abstract void save();

    public abstract void add(String s);
}
