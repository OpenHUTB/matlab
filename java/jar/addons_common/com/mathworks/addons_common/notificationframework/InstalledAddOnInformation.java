// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   InstalledAddOnInformation.java

package com.mathworks.addons_common.notificationframework;

import com.mathworks.addons_common.InstalledAddon;
import java.nio.file.Path;

public final class InstalledAddOnInformation
{

    public InstalledAddOnInformation(Path path, InstalledAddon installedaddon)
    {
        installedAddon = installedaddon;
        installedFolder = path;
    }

    public Path getInstalledFolder()
    {
        return installedFolder;
    }

    public InstalledAddon getInstalledAddon()
    {
        return installedAddon;
    }

    public void updateInstalledAddon(InstalledAddon installedaddon)
    {
        installedAddon = installedaddon;
    }

    private InstalledAddon installedAddon;
    private Path installedFolder;
}
