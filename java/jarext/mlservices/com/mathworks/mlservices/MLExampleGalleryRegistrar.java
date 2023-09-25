// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   MLExampleGalleryRegistrar.java

package com.mathworks.mlservices;


// Referenced classes of package com.mathworks.mlservices:
//            MLExampleGallery

public interface MLExampleGalleryRegistrar
{

    public abstract MLExampleGallery getExampleGallery();

    public static final String REGISTRAR_METHOD = "getExampleGallery";
}
