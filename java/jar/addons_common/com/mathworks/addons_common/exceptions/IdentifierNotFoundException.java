// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   IdentifierNotFoundException.java

package com.mathworks.addons_common.exceptions;


public final class IdentifierNotFoundException extends Exception
{

    public IdentifierNotFoundException(String s)
    {
        super((new StringBuilder()).append("There is no Installed Add-On existing in the cache with the identifier : ").append(s).toString());
    }
}
