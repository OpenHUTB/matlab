// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   EnableDisableManagementNotifierAPI.java

package com.mathworks.addons_common.notificationframework;

import com.mathworks.addons_common.InstalledAddon;

/**
 * @deprecated Interface EnableDisableManagementNotifierAPI is deprecated
 */

public interface EnableDisableManagementNotifierAPI
{

    public abstract void enable(InstalledAddon installedaddon);

    public abstract void disable(InstalledAddon installedaddon);

    public abstract void enableForAddonManagement(InstalledAddon installedaddon);

    public abstract void disableForAddonManagement(InstalledAddon installedaddon);

    public abstract void enableNonCoreServices(InstalledAddon installedaddon);

    public abstract void disableNonCoreServices(InstalledAddon installedaddon);
}
