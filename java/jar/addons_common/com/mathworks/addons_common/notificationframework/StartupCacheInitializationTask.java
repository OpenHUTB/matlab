// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   StartupCacheInitializationTask.java

package com.mathworks.addons_common.notificationframework;

import com.mathworks.addons_common.InstalledAddon;
import java.util.*;
import java.util.concurrent.Callable;

// Referenced classes of package com.mathworks.addons_common.notificationframework:
//            FolderRegistryInitializer, AddOnCollectionUtils, FolderRegistry, InstalledFolderRegistryObservers

final class StartupCacheInitializationTask
    implements Callable
{

    StartupCacheInitializationTask()
    {
    }

    public Map call()
    {
        Collection collection = AddOnCollectionUtils.collectInstalledProducts();
        AddOnCollectionUtils.retrieveImagesAsynchronously(collection);
        HashSet hashset = new HashSet(collection);
        Map map = AddOnCollectionUtils.convertInstalledAddonCollectionToCacheRepresentation(collection);
        if(!FolderRegistry.registryExists())
        {
            Collection collection1 = AddOnCollectionUtils.collectCommunityAddons();
            AddOnCollectionUtils.retrieveImagesAsynchronously(collection1);
            Map map1 = AddOnCollectionUtils.convertInstalledAddonCollectionToCacheRepresentation(collection1);
            if(!map1.isEmpty())
            {
                FolderRegistryInitializer folderregistryinitializer = new FolderRegistryInitializer();
                folderregistryinitializer.initialize(map1);
            }
        }
        java.util.List list = Arrays.asList(FolderRegistry.retrieveAllInstalledAddons());
        AddOnCollectionUtils.retrieveImagesAsynchronously(list);
        Map map2 = AddOnCollectionUtils.convertInstalledAddonCollectionToCacheRepresentation(list);
        map.putAll(map2);
        hashset.addAll(list);
        InstalledFolderRegistryObservers.initialize((InstalledAddon[])hashset.toArray(new InstalledAddon[0]));
        return map;
    }

    public volatile Object call()
        throws Exception
    {
        return call();
    }
}
