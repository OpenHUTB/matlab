// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   AddOnCollectionUtils.java

package com.mathworks.addons_common.notificationframework;

import com.mathworks.addons_common.*;
import com.mathworks.util.*;
import java.util.*;
import java.util.concurrent.*;

// Referenced classes of package com.mathworks.addons_common.notificationframework:
//            InstalledAddOnInformation

final class AddOnCollectionUtils
{

    AddOnCollectionUtils()
    {
    }

    static Collection collectInstalledProducts()
    {
        Collection collection = AddOnManagerImplementers.INSTANCE.get();
        ArrayList arraylist = new ArrayList();
        Iterator iterator = collection.iterator();
        do
        {
            if(!iterator.hasNext())
                break;
            AddonManager addonmanager = (AddonManager)iterator.next();
            if(addonmanager.getAddonTypeServiced().equalsIgnoreCase("product"))
                arraylist.add(addonmanager);
        } while(true);
        return getInstalledAddons(arraylist);
    }

    static Collection collectCommunityAddons()
    {
        ArrayList arraylist = new ArrayList();
        Collection collection = AddOnManagerImplementers.INSTANCE.get();
        Iterator iterator = collection.iterator();
        do
        {
            if(!iterator.hasNext())
                break;
            AddonManager addonmanager = (AddonManager)iterator.next();
            if(!addonmanager.getAddonTypeServiced().equals("support_package") && !addonmanager.getAddonTypeServiced().equals("product"))
                arraylist.add(addonmanager);
        } while(true);
        return getInstalledAddons(arraylist);
    }

    private static Collection getInstalledAddons(Collection collection)
    {
        ExecutorService executorservice;
        ArrayList arraylist;
        Iterator iterator1;
        if(FactoryUtils.isMatlabThread())
            throw new UnsupportedOperationException("Ths method cannot be called on the MATLAB thread.");
        executorservice = Executors.newCachedThreadPool(new NamedDaemonThreadFactory("GetInstalledAddons thread"));
        arraylist = new ArrayList();
        ArrayList arraylist1 = new ArrayList();
        Future future1;
        for(Iterator iterator = collection.iterator(); iterator.hasNext(); arraylist1.add(future1))
        {
            AddonManager addonmanager = (AddonManager)iterator.next();
            future1 = executorservice.submit(new Callable(addonmanager) {

                public Collection call()
                    throws Exception
                {
                    return AddOnCollectionUtils.getInstalledAddonsList(addonManager);
                }

                public volatile Object call()
                    throws Exception
                {
                    return call();
                }

                final AddonManager val$addonManager;

            
            {
                addonManager = addonmanager;
                super();
            }
            }
);
        }

        iterator1 = arraylist1.iterator();
_L2:
        Future future;
        if(!iterator1.hasNext())
            break; /* Loop/switch isn't completed */
        future = (Future)iterator1.next();
        try
        {
            arraylist.addAll((Collection)future.get());
        }
        catch(Object obj)
        {
            Log.logException(((Exception) (obj)));
        }
        if(true) goto _L2; else goto _L1
_L1:
        executorservice.shutdown();
        return arraylist;
    }

    private static List getInstalledAddonsList(AddonManager addonmanager)
    {
        InstalledAddon ainstalledaddon[] = addonmanager.getInstalled();
        return Arrays.asList(ainstalledaddon);
    }

    static Map convertInstalledAddonCollectionToCacheRepresentation(Collection collection)
    {
        ConcurrentHashMap concurrenthashmap = new ConcurrentHashMap();
        for(Iterator iterator = collection.iterator(); iterator.hasNext();)
        {
            InstalledAddon installedaddon = (InstalledAddon)iterator.next();
            InstalledAddOnInformation installedaddoninformation = new InstalledAddOnInformation(installedaddon.getInstalledFolder(), installedaddon);
            if(concurrenthashmap.containsKey(installedaddon.getIdentifier()))
            {
                Map map = (Map)concurrenthashmap.get(installedaddon.getIdentifier());
                map.put(installedaddon.getVersion(), installedaddoninformation);
            } else
            {
                ConcurrentHashMap concurrenthashmap1 = new ConcurrentHashMap();
                concurrenthashmap1.put(installedaddon.getVersion(), installedaddoninformation);
                concurrenthashmap.put(installedaddon.getIdentifier(), concurrenthashmap1);
            }
        }

        return concurrenthashmap;
    }

    static void retrieveImagesAsynchronously(Collection collection)
    {
        InstalledAddon installedaddon;
        for(Iterator iterator = collection.iterator(); iterator.hasNext(); installedaddon.retrieveImageAsynchronously())
            installedaddon = (InstalledAddon)iterator.next();

    }

    private static final String ADDON_TYPE_SUPPORT_PACKAGE = "support_package";
    private static final String ADDON_TYPE_PRODUCT = "product";

}
