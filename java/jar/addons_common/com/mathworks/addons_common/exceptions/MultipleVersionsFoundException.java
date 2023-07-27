// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   MultipleVersionsFoundException.java

package com.mathworks.addons_common.exceptions;


public final class MultipleVersionsFoundException extends Exception
{

    public MultipleVersionsFoundException(String s)
    {
        super((new StringBuilder()).append("Add-on with identifier : ").append(s).append(" has multiple versions installed").toString());
    }
}
