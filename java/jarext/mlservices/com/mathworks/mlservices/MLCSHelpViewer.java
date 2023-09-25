// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   MLCSHelpViewer.java

package com.mathworks.mlservices;


public interface MLCSHelpViewer
{

    public abstract String getCSHLocation();

    public abstract String getHtmlText();

    public abstract void displayTopic(String s, String s1);

    public abstract void displayTopic(Object obj, String s, String s1);

    public abstract void setLocation(int i, int j);

    public abstract void setSize(int i, int j);

    public abstract void close();
}
