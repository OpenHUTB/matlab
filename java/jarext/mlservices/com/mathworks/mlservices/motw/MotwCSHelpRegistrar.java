// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   MotwCSHelpRegistrar.java

package com.mathworks.mlservices.motw;

import com.mathworks.mlservices.MLCSHelpViewer;

public interface MotwCSHelpRegistrar
{

    public abstract MLCSHelpViewer getCSHelpViewer();

    public static final String REGISTRAR_METHOD = "getCSHelpViewer";
}
