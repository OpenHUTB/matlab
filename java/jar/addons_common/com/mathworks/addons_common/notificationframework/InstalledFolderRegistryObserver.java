// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   InstalledFolderRegistryObserver.java

package com.mathworks.addons_common.notificationframework;

import com.mathworks.addons_common.InstalledAddon;

public interface InstalledFolderRegistryObserver
{

    public abstract void initialize(InstalledAddon ainstalledaddon[]);

    public abstract void folderAdded(InstalledAddon installedaddon);

    public abstract void folderRemoved(InstalledAddon installedaddon);

    public abstract void refresh(InstalledAddon ainstalledaddon[]);
}
