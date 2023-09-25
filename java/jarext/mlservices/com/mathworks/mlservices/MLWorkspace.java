// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   MLWorkspace.java

package com.mathworks.mlservices;

import javax.swing.event.ChangeListener;

public interface MLWorkspace
{

    public abstract void invoke();

    public abstract String[] getSelectedNames();

    public abstract void setSelectedNames(String as[]);

    public abstract String[] getSelectedSizes();

    public abstract String[] getSelectedClasses();

    public abstract void addChronSelectionChangeListener(ChangeListener changelistener);

    public abstract void removeChronSelectionChangeListener(ChangeListener changelistener);
}
