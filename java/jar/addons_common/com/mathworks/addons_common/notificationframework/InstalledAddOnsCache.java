// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   InstalledAddOnsCache.java

package com.mathworks.addons_common.notificationframework;

import com.mathworks.addons_common.*;
import com.mathworks.addons_common.exceptions.*;
import com.mathworks.util.Log;
import com.mathworks.util.ThreadUtils;
import java.nio.file.Path;
import java.util.*;
import java.util.concurrent.*;

// Referenced classes of package com.mathworks.addons_common.notificationframework:
//            StartupCacheInitializationTask, AddOnInstallationObserverImpl, InstalledAddOnInformation, FolderRegistryInitializer, 
//            AddOnInstallationObserver, FolderRegistry, UINotifierRegistry, AddOnCollectionUtils, 
//            RegistrationManager, InstalledFolderRegistryObservers, AddonEnabledStateUtil

public final class InstalledAddOnsCache
{
    private static class LazyHolder
    {

        private static final InstalledAddOnsCache INSTANCE = new InstalledAddOnsCache();



        private LazyHolder()
        {
        }
    }


    private InstalledAddOnsCache()
    {
        executorService = ThreadUtils.newSingleDaemonThreadExecutor(com/mathworks/addons_common/notificationframework/InstalledAddOnsCache.getName());
        addAddOnInstallationObservers();
        installedAddOnsCacheFuture = executorService.submit(new StartupCacheInitializationTask());
    }

    private void addAddOnInstallationObservers()
    {
        AddOnInstallationObserverImpl addoninstallationobserverimpl = new AddOnInstallationObserverImpl();
        AddonManager addonmanager;
        for(Iterator iterator = AddOnManagerImplementers.INSTANCE.get().iterator(); iterator.hasNext(); addonmanager.addAddOnInstallationObserver(addoninstallationobserverimpl))
            addonmanager = (AddonManager)iterator.next();

    }

    public static InstalledAddOnsCache getInstance()
    {
        return LazyHolder.INSTANCE;
    }

    synchronized void resetCache()
    {
        Callable callable = createRefreshAndClearPersistenceDataTask(new InstalledAddon[0]);
        installedAddOnsCacheFuture = executorService.submit(callable);
    }

    public Map getInstalledAddOnsMap()
    {
        try
        {
            return (Map)installedAddOnsCacheFuture.get();
        }
        catch(Object obj)
        {
            Log.logException(((Exception) (obj)));
        }
        return Collections.emptyMap();
    }

    synchronized void add(InstalledAddon installedaddon)
    {
        Map map = getInstalledAddOnsMap();
        installedAddOnsCacheFuture = executorService.submit(getAddTask(map, installedaddon));
    }

    synchronized void add(InstalledAddon installedaddon, Path path, boolean flag)
    {
        Map map = getInstalledAddOnsMap();
        installedAddOnsCacheFuture = executorService.submit(getAddTask(map, installedaddon, path, flag));
    }

    Callable getAddTask(Map map, InstalledAddon installedaddon)
    {
        return getAddTask(map, installedaddon, installedaddon.getInstalledFolder(), true);
    }

    Callable getAddTask(final Map installedAddonMap, final InstalledAddon installedAddon, final Path installedFolder, final boolean enabled)
    {
        return new Callable() {

            public Map call()
                throws Exception
            {
                installedAddon.retrieveImageAsynchronously();
                installedAddon.setEnabled(enabled);
                InstalledAddOnInformation installedaddoninformation = new InstalledAddOnInformation(installedFolder, installedAddon);
                String s = installedAddon.getIdentifier();
                String s1 = installedAddon.getVersion();
                if(installedAddonMap.containsKey(s))
                {
                    Map map = (Map)installedAddonMap.get(s);
                    map.put(s1, installedaddoninformation);
                } else
                {
                    ConcurrentHashMap concurrenthashmap = new ConcurrentHashMap();
                    concurrenthashmap.put(s1, installedaddoninformation);
                    installedAddonMap.put(s, concurrenthashmap);
                }
                UINotifierRegistry.notifyAdded(installedAddon);
                InstalledFolderRegistryObservers.folderAdded(installedAddon);
                return installedAddonMap;
            }

            public volatile Object call()
                throws Exception
            {
                return call();
            }

            final InstalledAddon val$installedAddon;
            final boolean val$enabled;
            final Path val$installedFolder;
            final Map val$installedAddonMap;
            final InstalledAddOnsCache this$0;

            
            {
                this$0 = InstalledAddOnsCache.this;
                installedAddon = installedaddon;
                enabled = flag;
                installedFolder = path;
                installedAddonMap = map;
                super();
            }
        }
;
    }

    synchronized void update(InstalledAddon installedaddon)
    {
        Map map = getInstalledAddOnsMap();
        installedAddOnsCacheFuture = executorService.submit(getUpdateTask(installedaddon, map));
    }

    Callable getUpdateTask(final InstalledAddon installedAddon, final Map installedAddonMap)
    {
        return new Callable() {

            public Map call()
                throws Exception
            {
                installedAddon.retrieveImageAsynchronously();
                String s = installedAddon.getIdentifier();
                String s1 = installedAddon.getVersion();
                if(installedAddonMap.containsKey(s))
                {
                    Map map = (Map)installedAddonMap.get(s);
                    if(map.containsKey(s1))
                    {
                        InstalledAddOnInformation installedaddoninformation = (InstalledAddOnInformation)map.get(s1);
                        installedaddoninformation.updateInstalledAddon(installedAddon);
                        map.put(s1, installedaddoninformation);
                        UINotifierRegistry.notifyUpdated(installedAddon);
                    }
                }
                return installedAddonMap;
            }

            public volatile Object call()
                throws Exception
            {
                return call();
            }

            final InstalledAddon val$installedAddon;
            final Map val$installedAddonMap;
            final InstalledAddOnsCache this$0;

            
            {
                this$0 = InstalledAddOnsCache.this;
                installedAddon = installedaddon;
                installedAddonMap = map;
                super();
            }
        }
;
    }

    synchronized void remove(InstalledAddon installedaddon)
    {
        Map map = getInstalledAddOnsMap();
        installedAddOnsCacheFuture = executorService.submit(getRemoveTask(map, installedaddon));
    }

    Callable getRemoveTask(final Map installedAddonMap, final InstalledAddon installedAddon)
    {
        return new Callable() {

            public Map call()
                throws Exception
            {
                String s = installedAddon.getIdentifier();
                String s1 = installedAddon.getVersion();
                if(installedAddonMap.containsKey(s))
                {
                    Map map = (Map)installedAddonMap.get(s);
                    map.remove(s1);
                    UINotifierRegistry.notifyRemoved(installedAddon);
                    InstalledFolderRegistryObservers.folderRemoved(installedAddon);
                    if(map.isEmpty())
                        installedAddonMap.remove(s);
                }
                return installedAddonMap;
            }

            public volatile Object call()
                throws Exception
            {
                return call();
            }

            final InstalledAddon val$installedAddon;
            final Map val$installedAddonMap;
            final InstalledAddOnsCache this$0;

            
            {
                this$0 = InstalledAddOnsCache.this;
                installedAddon = installedaddon;
                installedAddonMap = map;
                super();
            }
        }
;
    }

    public synchronized InstalledAddon retrieveAddOnWithIdentifier(String s)
        throws IdentifierNotFoundException, MultipleVersionsFoundException
    {
        Map map = getInstalledAddOnsMap();
        if(map.containsKey(s))
        {
            Map map1 = (Map)map.get(s);
            if(map1.size() == 0)
                throw new IdentifierNotFoundException(s);
            if(map1.size() > 1)
                throw new MultipleVersionsFoundException(s);
            Iterator iterator = map1.values().iterator();
            if(iterator.hasNext())
            {
                InstalledAddOnInformation installedaddoninformation = (InstalledAddOnInformation)iterator.next();
                return installedaddoninformation.getInstalledAddon();
            }
        }
        throw new IdentifierNotFoundException(s);
    }

    public synchronized boolean hasMultipleVersionsInstalled(String s)
    {
        Map map = getInstalledAddOnsMap();
        if(map.containsKey(s))
        {
            Map map1 = (Map)map.get(s);
            if(map1.size() > 1)
                return true;
        }
        return false;
    }

    public synchronized InstalledAddon retrieveAddOnWithIdentifierAndVersion(String s, String s1)
        throws AddOnNotFoundException
    {
        InstalledAddOnInformation installedaddoninformation = retrieveInstalledAddOnInformationForIdentifierAndVersion(s, s1);
        return installedaddoninformation.getInstalledAddon();
    }

    public synchronized InstalledAddon retrieveEnabledAddOnVersion(String s)
    {
label0:
        {
            if(!hasEnabledVersion(s))
                break label0;
            Map map = getInstalledAddOnsMap();
            Map map1 = (Map)map.get(s);
            Iterator iterator = map1.values().iterator();
            InstalledAddon installedaddon;
            do
            {
                if(!iterator.hasNext())
                    break label0;
                InstalledAddOnInformation installedaddoninformation = (InstalledAddOnInformation)iterator.next();
                installedaddon = installedaddoninformation.getInstalledAddon();
            } while(!installedaddon.isEnabled());
            return installedaddon;
        }
        throw new UnsupportedOperationException((new StringBuilder()).append("No enabled version exists for the add-on with identifier: ").append(s).toString());
    }

    public synchronized boolean hasAddonWithIdentifier(String s)
    {
        Map map = getInstalledAddOnsMap();
        return map.containsKey(s);
    }

    public synchronized boolean hasAddonWithIdentifierAndVersion(String s, String s1)
    {
        Map map = getInstalledAddOnsMap();
        if(map.containsKey(s))
        {
            Map map1 = (Map)map.get(s);
            if(map1.containsKey(s1))
                return true;
        }
        return false;
    }

    public synchronized boolean hasEnabledVersion(String s)
    {
label0:
        {
            if(!hasAddonWithIdentifier(s))
                break label0;
            Map map = getInstalledAddOnsMap();
            Map map1 = (Map)map.get(s);
            Iterator iterator = map1.values().iterator();
            InstalledAddon installedaddon;
            do
            {
                if(!iterator.hasNext())
                    break label0;
                InstalledAddOnInformation installedaddoninformation = (InstalledAddOnInformation)iterator.next();
                installedaddon = installedaddoninformation.getInstalledAddon();
            } while(!installedaddon.isEnabled());
            return true;
        }
        return false;
    }

    public synchronized void updateAddonState(InstalledAddon installedaddon, boolean flag)
    {
        try
        {
            if(FolderRegistry.hasEntryWithIdentifierAndVersion(installedaddon.getIdentifier(), installedaddon.getVersion()))
            {
                FolderRegistry.update(installedaddon.getIdentifier(), installedaddon.getVersion(), flag);
                UINotifierRegistry.notifyUpdated(installedaddon);
            }
        }
        catch(Exception exception)
        {
            Log.logException(exception);
        }
    }

    public synchronized void refreshCache()
    {
        InstalledAddon ainstalledaddon[] = getInstalledAddonsAsArray();
        installedAddOnsCacheFuture = executorService.submit(createRefreshTask(ainstalledaddon));
    }

    /**
     * @deprecated Method refreshCacheAndClearPersistenceData is deprecated
     */

    public synchronized void refreshCacheAndClearPersistenceData()
    {
        InstalledAddon ainstalledaddon[] = getInstalledAddonsAsArray();
        installedAddOnsCacheFuture = executorService.submit(createRefreshAndClearPersistenceDataTask(ainstalledaddon));
    }

    Callable createRefreshAndClearPersistenceDataTask(final InstalledAddon installedAddonsBeforeRefresh[])
    {
        final FolderRegistryInitializer folderRegistryInitializer = new FolderRegistryInitializer();
        return new Callable() {

            public Map call()
            {
                clearPersistenceData();
                return refreshCache(installedAddonsBeforeRefresh, folderRegistryInitializer);
            }

            public volatile Object call()
                throws Exception
            {
                return call();
            }

            final InstalledAddon val$installedAddonsBeforeRefresh[];
            final FolderRegistryInitializer val$folderRegistryInitializer;
            final InstalledAddOnsCache this$0;

            
            {
                this$0 = InstalledAddOnsCache.this;
                installedAddonsBeforeRefresh = ainstalledaddon;
                folderRegistryInitializer = folderregistryinitializer;
                super();
            }
        }
;
    }

    Callable createRefreshTask(final InstalledAddon installedAddonsBeforeRefresh[])
    {
        final FolderRegistryInitializer folderRegistryInitializer = new FolderRegistryInitializer();
        return new Callable() {

            public Map call()
            {
                return refreshCache(installedAddonsBeforeRefresh, folderRegistryInitializer);
            }

            public volatile Object call()
                throws Exception
            {
                return call();
            }

            final InstalledAddon val$installedAddonsBeforeRefresh[];
            final FolderRegistryInitializer val$folderRegistryInitializer;
            final InstalledAddOnsCache this$0;

            
            {
                this$0 = InstalledAddOnsCache.this;
                installedAddonsBeforeRefresh = ainstalledaddon;
                folderRegistryInitializer = folderregistryinitializer;
                super();
            }
        }
;
    }

    private Map refreshCache(InstalledAddon ainstalledaddon[], FolderRegistryInitializer folderregistryinitializer)
    {
        ArrayList arraylist = new ArrayList(Arrays.asList(ainstalledaddon));
        Iterator iterator = arraylist.iterator();
        do
        {
            if(!iterator.hasNext())
                break;
            InstalledAddon installedaddon = (InstalledAddon)iterator.next();
            String s = installedaddon.getType();
            if(!s.equalsIgnoreCase("support_package") && !s.equalsIgnoreCase("product"))
                iterator.remove();
        } while(true);
        Map map = AddOnCollectionUtils.convertInstalledAddonCollectionToCacheRepresentation(arraylist);
        Collection collection = AddOnCollectionUtils.collectCommunityAddons();
        AddOnCollectionUtils.retrieveImagesAsynchronously(collection);
        Map map1 = AddOnCollectionUtils.convertInstalledAddonCollectionToCacheRepresentation(collection);
        folderregistryinitializer.initialize(map1);
        RegistrationManager.registerEnabledAddons(map1);
        map.putAll(map1);
        Collection collection1 = retrieveInstalledAddons(map);
        UINotifierRegistry.notifyRefreshed(collection1);
        InstalledFolderRegistryObservers.refresh((InstalledAddon[])collection1.toArray(new InstalledAddon[collection1.size()]));
        return map;
    }

    private void clearPersistenceData()
    {
        FolderRegistry.deleteFolderRegistrySettingPath();
    }

    public synchronized InstalledAddon[] getInstalledAddonsAsArray()
    {
        try
        {
            Collection collection = retrieveInstalledAddons((Map)installedAddOnsCacheFuture.get());
            return (InstalledAddon[])collection.toArray(new InstalledAddon[collection.size()]);
        }
        catch(Object obj)
        {
            Log.logException(((Exception) (obj)));
        }
        return new InstalledAddon[0];
    }

    public synchronized boolean isAddonEnabled(String s, String s1)
        throws AddOnNotFoundException
    {
        return AddonEnabledStateUtil.isEnabled(s, s1);
    }

    public synchronized InstalledAddon getMostRecentlyInstalledVersion(String s)
        throws IdentifierNotFoundException
    {
        Map map = getInstalledAddOnsMap();
        if(map.containsKey(s))
        {
            Map map1 = (Map)map.get(s);
            InstalledAddon installedaddon = ((InstalledAddOnInformation)map1.values().iterator().next()).getInstalledAddon();
            for(Iterator iterator = map1.values().iterator(); iterator.hasNext();)
            {
                InstalledAddOnInformation installedaddoninformation = (InstalledAddOnInformation)iterator.next();
                installedaddon = installedaddoninformation.getInstalledAddon().getInstalledDate().compareTo(installedaddon.getInstalledDate()) >= 0 ? installedaddon : installedaddoninformation.getInstalledAddon();
            }

            return installedaddon;
        } else
        {
            throw new IdentifierNotFoundException(s);
        }
    }

    private InstalledAddOnInformation retrieveInstalledAddOnInformationForIdentifierAndVersion(String s, String s1)
        throws AddOnNotFoundException
    {
        Map map = getInstalledAddOnsMap();
        if(map.containsKey(s))
        {
            Map map1 = (Map)map.get(s);
            if(map1.containsKey(s1))
                return (InstalledAddOnInformation)map1.get(s1);
        }
        throw new AddOnNotFoundException(s, s1);
    }

    private Collection retrieveInstalledAddons(Map map)
    {
        HashSet hashset = new HashSet();
        for(Iterator iterator = map.values().iterator(); iterator.hasNext();)
        {
            Map map1 = (Map)iterator.next();
            Iterator iterator1 = map1.values().iterator();
            while(iterator1.hasNext()) 
            {
                InstalledAddOnInformation installedaddoninformation = (InstalledAddOnInformation)iterator1.next();
                hashset.add(installedaddoninformation.getInstalledAddon());
            }
        }

        return hashset;
    }

    public InstalledAddon retrieveInstalledAddOnForFolder(Path path)
        throws RuntimeException
    {
        InstalledAddon ainstalledaddon[] = getInstalledAddonsAsArray();
        InstalledAddon ainstalledaddon1[] = ainstalledaddon;
        int i = ainstalledaddon1.length;
        for(int j = 0; j < i; j++)
        {
            InstalledAddon installedaddon = ainstalledaddon1[j];
            if(path.equals(installedaddon.getInstalledFolder()))
                return installedaddon;
        }

        throw new RuntimeException((new StringBuilder()).append("Did not find an installed add-on in the cache with the folder ").append(path.toString()).toString());
    }


    private static final String ADDON_TYPE_SUPPORT_PACKAGE = "support_package";
    private static final String ADDON_TYPE_PRODUCT = "product";
    private static Future installedAddOnsCacheFuture;
    private ExecutorService executorService;


}
