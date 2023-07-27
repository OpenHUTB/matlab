// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   InstalledAddonConversionException.java

package com.mathworks.addons_common.exceptions;


public final class InstalledAddonConversionException extends Exception
{

    public InstalledAddonConversionException(String s)
    {
        super((new StringBuilder()).append("Could not create InstalledAddon for Folder : ").append(s).toString());
    }
}
