// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   MatlabPauseObserver.java

package com.mathworks.mlservices;

import java.util.EventListener;

public interface MatlabPauseObserver
    extends EventListener
{

    public abstract void doPause();
}
