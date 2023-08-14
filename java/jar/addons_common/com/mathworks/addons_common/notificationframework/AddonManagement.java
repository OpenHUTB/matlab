// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   AddonManagement.java

package com.mathworks.addons_common.notificationframework;

import com.mathworks.addons_common.InstalledAddon;
import com.mathworks.addons_common.exceptions.AddOnNotFoundException;
import com.mathworks.addons_common.exceptions.IdentifierNotFoundException;
import com.mathworks.addons_common.util.settings.InstallationFolderUtils;
import com.mathworks.util.Log;
import java.nio.file.Path;

// Referenced classes of package com.mathworks.addons_common.notificationframework:
//            InstalledAddOnsCache, AddOnManagementRegistrationFrameworkAdapter, EnableDisableManagementNotifier, FolderRegistry, 
//            Uninstaller

public final class AddonManagement
{

    private AddonManagement()
    {
    }

    public static synchronized void disableAddOn(String s, String s1)
    {
        try
        {
            InstalledAddon installedaddon = InstalledAddOnsCache.getInstance().retrieveAddOnWithIdentifierAndVersion(s, s1);
            disableAddOn(installedaddon);
        }
        catch(AddOnNotFoundException addonnotfoundexception)
        {
            Log.logException(addonnotfoundexception);
        }
    }

    public static synchronized void enableAddOn(String s, String s1)
        throws IdentifierNotFoundException
    {
        disableOtherEnabledVersion(s, s1);
        try
        {
            InstalledAddon installedaddon = InstalledAddOnsCache.getInstance().retrieveAddOnWithIdentifierAndVersion(s, s1);
            enableAddOn(installedaddon);
        }
        catch(AddOnNotFoundException addonnotfoundexception)
        {
            Log.logException(addonnotfoundexception);
        }
    }

    public static synchronized void addFolder(Path path, InstalledAddon installedaddon)
    {
        disableOtherEnabledVersion(installedaddon.getIdentifier(), installedaddon.getVersion());
        boolean flag = true;
        InstalledAddOnsCache.getInstance().add(installedaddon, path, flag);
        AddOnManagementRegistrationFrameworkAdapter.addAddOn(installedaddon.getIdentifier(), installedaddon.getVersion(), flag, path);
        if(installedaddon.isEnableDisableSupported())
            EnableDisableManagementNotifier.notifyToEnable(installedaddon);
        try
        {
            InstallationFolderUtils.initializeSetting();
        }
        catch(Exception exception)
        {
            Log.logException(exception);
        }
    }

    public static synchronized void addFolderFromMatlabApi(Path path, InstalledAddon installedaddon)
    {
        boolean flag = true;
        InstalledAddOnsCache.getInstance().add(installedaddon, path, flag);
        if(!FolderRegistry.hasEntryWithIdentifierAndVersion(installedaddon.getIdentifier(), installedaddon.getVersion()))
            FolderRegistry.add(installedaddon.getIdentifier(), installedaddon.getVersion(), flag, path);
        if(installedaddon.isEnableDisableSupported())
            EnableDisableManagementNotifier.notifyToEnableNonCoreServices(installedaddon);
        try
        {
            InstallationFolderUtils.initializeSetting();
        }
        catch(Exception exception)
        {
            Log.logException(exception);
        }
    }

    public static synchronized void removeFolder(Path path, InstalledAddon installedaddon)
    {
        try
        {
            InstalledAddOnsCache.getInstance().remove(installedaddon);
            if(FolderRegistry.hasEntryWithIdentifierAndVersion(installedaddon.getIdentifier(), installedaddon.getVersion()))
                FolderRegistry.remove(installedaddon.getIdentifier(), installedaddon.getVersion());
        }
        catch(RuntimeException runtimeexception) { }
    }

    public static synchronized void uninstall(String s, String s1)
        throws Exception
    {
        Uninstaller.uninstall(s, s1);
    }

    public static synchronized void uninstallSilent(String s, String s1)
        throws Exception
    {
        Uninstaller.uninstallSilent(s, s1);
    }

    public static synchronized void uninstallFromMatlabAPI(String s, String s1)
        throws Exception
    {
        Uninstaller.uninstallFromMatlabAPI(s, s1);
    }

    private static void disableOtherEnabledVersion(String s, String s1)
    {
        if(InstalledAddOnsCache.getInstance().hasEnabledVersion(s))
        {
            InstalledAddon installedaddon = InstalledAddOnsCache.getInstance().retrieveEnabledAddOnVersion(s);
            if(!installedaddon.getVersion().equalsIgnoreCase(s1))
                disableAddOn(installedaddon);
        }
    }

    private static void disableAddOn(InstalledAddon installedaddon)
    {
        if(installedaddon.isEnableDisableSupported())
        {
            AddOnManagementRegistrationFrameworkAdapter.disableAddOn(installedaddon.getIdentifier(), installedaddon.getVersion());
            EnableDisableManagementNotifier.notifyToDisableForAddonManagement(installedaddon);
        }
    }

    private static void enableAddOn(InstalledAddon installedaddon)
    {
        if(installedaddon.isEnableDisableSupported())
        {
            AddOnManagementRegistrationFrameworkAdapter.enableAddOn(installedaddon.getIdentifier(), installedaddon.getVersion());
            EnableDisableManagementNotifier.notifyToEnableForAddonManagement(installedaddon);
        }
    }
}
