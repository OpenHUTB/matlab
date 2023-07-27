// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   AddOnInstallationObserver.java

package com.mathworks.addons_common.notificationframework;

import com.mathworks.addons_common.InstalledAddon;
import com.mathworks.addons_common.OpenUrlMessage;
import java.nio.file.Path;

/**
 * @deprecated Interface AddOnInstallationObserver is deprecated
 */

public interface AddOnInstallationObserver
{

    /**
     * @deprecated Method notifyInstalled is deprecated
     */

    public abstract void notifyInstalled(InstalledAddon installedaddon);

    public abstract void notifyInstalled(InstalledAddon installedaddon, Path path);

    public abstract void notifyUninstalled(InstalledAddon installedaddon);

    public abstract void notifyUpdated(InstalledAddon installedaddon);

    public abstract void notifyUninstalled(InstalledAddon installedaddon, String s);

    public abstract void notifyInstallFailed(String s, String s1);

    public abstract void notifyUninstallFailed(String s, String s1);

    /**
     * @deprecated Method openUrl is deprecated
     */

    public abstract void openUrl(OpenUrlMessage openurlmessage);
}
