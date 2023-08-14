// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   FolderRegistryInitializer.java

package com.mathworks.addons_common.notificationframework;

import com.mathworks.addons_common.InstalledAddon;
import com.mathworks.addons_common.util.VersionComparator;
import com.mathworks.util.Log;
import java.util.*;

// Referenced classes of package com.mathworks.addons_common.notificationframework:
//            InstalledAddOnInformation, FolderRegistry

final class FolderRegistryInitializer
{

    FolderRegistryInitializer()
    {
    }

    void initialize(Map map)
    {
        try
        {
            Set set = map.keySet();
            InstalledAddon installedaddon;
            for(Iterator iterator = set.iterator(); iterator.hasNext(); FolderRegistry.update(installedaddon.getIdentifier(), installedaddon.getVersion(), true))
            {
                String s = (String)iterator.next();
                Map map1 = (Map)map.get(s);
                Set set1 = map1.keySet();
                String s1 = "-1";
                InstalledAddon installedaddon1;
                java.nio.file.Path path;
                for(Iterator iterator1 = set1.iterator(); iterator1.hasNext(); FolderRegistry.add(installedaddon1.getIdentifier(), installedaddon1.getVersion(), installedaddon1.isEnabled(), path))
                {
                    String s2 = (String)iterator1.next();
                    boolean flag = VersionComparator.compare(s1, s2) == 1;
                    if(flag)
                        s1 = s2;
                    InstalledAddOnInformation installedaddoninformation1 = (InstalledAddOnInformation)map1.get(s2);
                    installedaddon1 = installedaddoninformation1.getInstalledAddon();
                    installedaddon1.setEnabled(false);
                    path = installedaddon1.getInstalledFolder();
                }

                InstalledAddOnInformation installedaddoninformation = (InstalledAddOnInformation)map1.get(s1);
                installedaddon = installedaddoninformation.getInstalledAddon();
                installedaddon.setEnabled(true);
            }

        }
        catch(Exception exception)
        {
            Log.logException(exception);
        }
    }
}
