// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   MotwHelpRegistrar.java

package com.mathworks.mlservices.motw;

import com.mathworks.mlservices.MLHelpBrowser;

public interface MotwHelpRegistrar
{

    public abstract MLHelpBrowser getHelpBrowser();

    public static final String REGISTRAR_METHOD = "getHelpBrowser";
}
