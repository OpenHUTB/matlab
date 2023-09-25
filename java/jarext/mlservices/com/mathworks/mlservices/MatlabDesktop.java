// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   MatlabDesktop.java

package com.mathworks.mlservices;


public interface MatlabDesktop
{

    public abstract void showCommandWindow();

    public abstract void showCommandHistory();

    public abstract void showFileBrowser();

    public abstract void showWorkspaceBrowser();

    public abstract void showHelpBrowser();

    public abstract void showProfiler();

    public abstract void closeCommandWindow();

    public abstract void closeCommandHistory();

    public abstract void closeFileBrowser();

    public abstract void closeWorkspaceBrowser();

    public abstract void closeHelpBrowser();

    public abstract void closeProfiler();

    public abstract void setDefaultLayout();

    public abstract void setCommandOnlyLayout();

    public abstract void setCommandAndHistoryLayout();
}
