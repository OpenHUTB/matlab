// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   MLCommandHistoryRegistrar.java

package com.mathworks.mlservices;


// Referenced classes of package com.mathworks.mlservices:
//            MLCommandHistory

public interface MLCommandHistoryRegistrar
{

    public abstract MLCommandHistory getCommandHistory();

    public static final String REGISTRAR_METHOD = "getCommandHistory";
}
