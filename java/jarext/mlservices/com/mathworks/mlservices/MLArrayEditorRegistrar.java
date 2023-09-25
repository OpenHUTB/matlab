// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   MLArrayEditorRegistrar.java

package com.mathworks.mlservices;


// Referenced classes of package com.mathworks.mlservices:
//            MLArrayEditor

public interface MLArrayEditorRegistrar
{

    public abstract MLArrayEditor getArrayEditor();

    public static final String REGISTRAR_METHOD = "getArrayEditor";
}
