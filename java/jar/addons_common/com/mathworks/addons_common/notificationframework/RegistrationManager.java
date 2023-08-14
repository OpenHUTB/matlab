// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   RegistrationManager.java

package com.mathworks.addons_common.notificationframework;

import com.mathworks.addons_common.InstalledAddon;
import com.mathworks.util.ParameterRunnable;
import java.util.*;

// Referenced classes of package com.mathworks.addons_common.notificationframework:
//            InstalledAddOnInformation, InstalledAddOnsCache, EnableDisableManagementNotifier

public final class RegistrationManager
{

    public RegistrationManager()
    {
    }

    public static void registerEnabledAddons(Map map)
    {
        ParameterRunnable parameterrunnable = new ParameterRunnable() {

            public void run(InstalledAddon installedaddon)
            {
                if(installedaddon.isEnabled())
                    EnableDisableManagementNotifier.notifyToEnable(installedaddon);
            }

            public volatile void run(Object obj)
            {
                run((InstalledAddon)obj);
            }

        }
;
        registerAddons(map, parameterrunnable);
    }

    public static void registerDisabledAddonsNonCoreServices()
    {
        ParameterRunnable parameterrunnable = new ParameterRunnable() {

            public void run(InstalledAddon installedaddon)
            {
                if(!installedaddon.isEnabled())
                    EnableDisableManagementNotifier.notifyToDisableNonCoreServices(installedaddon);
            }

            public volatile void run(Object obj)
            {
                run((InstalledAddon)obj);
            }

        }
;
        if(!hasRegisteredDisabledAddons)
        {
            Map map = InstalledAddOnsCache.getInstance().getInstalledAddOnsMap();
            registerAddons(map, parameterrunnable);
            hasRegisteredDisabledAddons = true;
        }
    }

    private static void registerAddons(Map map, ParameterRunnable parameterrunnable)
    {
        Set set = map.keySet();
        for(Iterator iterator = set.iterator(); iterator.hasNext();)
        {
            String s = (String)iterator.next();
            Map map1 = (Map)map.get(s);
            Set set1 = map1.keySet();
            Iterator iterator1 = set1.iterator();
            while(iterator1.hasNext()) 
            {
                String s1 = (String)iterator1.next();
                InstalledAddOnInformation installedaddoninformation = (InstalledAddOnInformation)map1.get(s1);
                InstalledAddon installedaddon = installedaddoninformation.getInstalledAddon();
                if(installedaddon.isEnableDisableSupported())
                    parameterrunnable.run(installedaddon);
            }
        }

    }

    private static boolean hasRegisteredDisabledAddons = false;

}
