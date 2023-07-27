// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   EnableDisableManagementNotifier.java

package com.mathworks.addons_common.notificationframework;

import com.mathworks.addons_common.InstalledAddon;
import com.mathworks.util.ImplementorsCache;
import com.mathworks.util.ImplementorsCacheFactory;
import java.util.Collection;
import java.util.Iterator;

// Referenced classes of package com.mathworks.addons_common.notificationframework:
//            EnableDisableManagementNotifierAPI

public final class EnableDisableManagementNotifier
{

    private EnableDisableManagementNotifier()
    {
    }

    public static void notifyToEnable(InstalledAddon installedaddon)
    {
        initializeNotifier();
        EnableDisableManagementNotifierAPI enabledisablemanagementnotifierapi;
        for(Iterator iterator = notifiers.iterator(); iterator.hasNext(); enabledisablemanagementnotifierapi.enable(installedaddon))
            enabledisablemanagementnotifierapi = (EnableDisableManagementNotifierAPI)iterator.next();

    }

    public static void notifyToDisable(InstalledAddon installedaddon)
    {
        initializeNotifier();
        EnableDisableManagementNotifierAPI enabledisablemanagementnotifierapi;
        for(Iterator iterator = notifiers.iterator(); iterator.hasNext(); enabledisablemanagementnotifierapi.disable(installedaddon))
            enabledisablemanagementnotifierapi = (EnableDisableManagementNotifierAPI)iterator.next();

    }

    static void notifyToEnableForAddonManagement(InstalledAddon installedaddon)
    {
        initializeNotifier();
        EnableDisableManagementNotifierAPI enabledisablemanagementnotifierapi;
        for(Iterator iterator = notifiers.iterator(); iterator.hasNext(); enabledisablemanagementnotifierapi.enableForAddonManagement(installedaddon))
            enabledisablemanagementnotifierapi = (EnableDisableManagementNotifierAPI)iterator.next();

    }

    static void notifyToDisableForAddonManagement(InstalledAddon installedaddon)
    {
        initializeNotifier();
        EnableDisableManagementNotifierAPI enabledisablemanagementnotifierapi;
        for(Iterator iterator = notifiers.iterator(); iterator.hasNext(); enabledisablemanagementnotifierapi.disableForAddonManagement(installedaddon))
            enabledisablemanagementnotifierapi = (EnableDisableManagementNotifierAPI)iterator.next();

    }

    static void notifyToEnableNonCoreServices(InstalledAddon installedaddon)
    {
        initializeNotifier();
        EnableDisableManagementNotifierAPI enabledisablemanagementnotifierapi;
        for(Iterator iterator = notifiers.iterator(); iterator.hasNext(); enabledisablemanagementnotifierapi.enableNonCoreServices(installedaddon))
            enabledisablemanagementnotifierapi = (EnableDisableManagementNotifierAPI)iterator.next();

    }

    static void notifyToDisableNonCoreServices(InstalledAddon installedaddon)
    {
        initializeNotifier();
        EnableDisableManagementNotifierAPI enabledisablemanagementnotifierapi;
        for(Iterator iterator = notifiers.iterator(); iterator.hasNext(); enabledisablemanagementnotifierapi.disableNonCoreServices(installedaddon))
            enabledisablemanagementnotifierapi = (EnableDisableManagementNotifierAPI)iterator.next();

    }

    private static void initializeNotifier()
    {
        if(notifiers == null)
            notifiers = ImplementorsCacheFactory.getInstance().getImplementors(com/mathworks/addons_common/notificationframework/EnableDisableManagementNotifierAPI);
    }

    private static Collection notifiers = null;

}
