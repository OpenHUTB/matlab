// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   MatlabExecutionErrorHandler.java

package com.mathworks.mlservices;

import com.mathworks.mvm.exec.MvmException;

public interface MatlabExecutionErrorHandler
{

    public abstract void handleError(MvmException mvmexception);
}
