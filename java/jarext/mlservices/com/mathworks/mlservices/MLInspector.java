// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   MLInspector.java

package com.mathworks.mlservices;

import com.mathworks.services.ObjectRegistry;

public interface MLInspector
{

    public abstract void invoke();

    public abstract void inspectObject(Object obj);

    public abstract void inspectObjectArray(Object aobj[]);

    public abstract void inspectObject(Object obj, boolean flag);

    public abstract void inspectObjectArray(Object aobj[], boolean flag);

    public abstract void selectProperty(String s);

    public abstract void refreshIfOpen();

    public abstract void inspectIfOpen(Object obj);

    public abstract void activateInspector();

    public abstract boolean isInspectorOpen();

    public abstract void closeWindow();

    public abstract void setShowReadOnly(boolean flag);

    public abstract String getMixedValueDisplay();

    public abstract void toFront();

    public abstract ObjectRegistry getRegistry();

    public abstract void setAutoUpdate(boolean flag);

    public abstract boolean isAutoUpdate();
}
