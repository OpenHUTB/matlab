// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   InstalledFolderRegistryObservers.java

package com.mathworks.addons_common.notificationframework;

import com.mathworks.addons_common.InstalledAddon;
import com.mathworks.util.*;
import java.util.Collection;
import java.util.Iterator;
import java.util.concurrent.ExecutorService;

// Referenced classes of package com.mathworks.addons_common.notificationframework:
//            InstalledFolderRegistryObserver

final class InstalledFolderRegistryObservers
{

    private InstalledFolderRegistryObservers()
    {
    }

    static void initialize(InstalledAddon ainstalledaddon[])
    {
        initializeInstalledFolderRegistryObserversCollection();
        executorService.submit(initializeTask(ainstalledaddon));
    }

    static void folderAdded(InstalledAddon installedaddon)
    {
        initializeInstalledFolderRegistryObserversCollection();
        executorService.submit(folderAddedTask(installedaddon));
    }

    static void folderRemoved(InstalledAddon installedaddon)
    {
        initializeInstalledFolderRegistryObserversCollection();
        executorService.submit(folderRemovedTask(installedaddon));
    }

    static void refresh(InstalledAddon ainstalledaddon[])
    {
        initializeInstalledFolderRegistryObserversCollection();
        executorService.submit(foldersRefreshed(ainstalledaddon));
    }

    private static Runnable folderAddedTask(InstalledAddon installedaddon)
    {
        return new Runnable(installedaddon) {

            public void run()
            {
                InstalledFolderRegistryObserver installedfolderregistryobserver;
                for(Iterator iterator = InstalledFolderRegistryObservers.installedFolderRegistryObservers.iterator(); iterator.hasNext(); installedfolderregistryobserver.folderAdded(installedAddon))
                    installedfolderregistryobserver = (InstalledFolderRegistryObserver)iterator.next();

            }

            final InstalledAddon val$installedAddon;

            
            {
                installedAddon = installedaddon;
                super();
            }
        }
;
    }

    private static Runnable initializeTask(InstalledAddon ainstalledaddon[])
    {
        return new Runnable(ainstalledaddon) {

            public void run()
            {
                InstalledFolderRegistryObserver installedfolderregistryobserver;
                for(Iterator iterator = InstalledFolderRegistryObservers.installedFolderRegistryObservers.iterator(); iterator.hasNext(); installedfolderregistryobserver.initialize(installedAddons))
                    installedfolderregistryobserver = (InstalledFolderRegistryObserver)iterator.next();

            }

            final InstalledAddon val$installedAddons[];

            
            {
                installedAddons = ainstalledaddon;
                super();
            }
        }
;
    }

    private static Runnable folderRemovedTask(InstalledAddon installedaddon)
    {
        return new Runnable(installedaddon) {

            public void run()
            {
                InstalledFolderRegistryObserver installedfolderregistryobserver;
                for(Iterator iterator = InstalledFolderRegistryObservers.installedFolderRegistryObservers.iterator(); iterator.hasNext(); installedfolderregistryobserver.folderRemoved(installedAddon))
                    installedfolderregistryobserver = (InstalledFolderRegistryObserver)iterator.next();

            }

            final InstalledAddon val$installedAddon;

            
            {
                installedAddon = installedaddon;
                super();
            }
        }
;
    }

    private static Runnable foldersRefreshed(InstalledAddon ainstalledaddon[])
    {
        return new Runnable(ainstalledaddon) {

            public void run()
            {
                InstalledFolderRegistryObserver installedfolderregistryobserver;
                for(Iterator iterator = InstalledFolderRegistryObservers.installedFolderRegistryObservers.iterator(); iterator.hasNext(); installedfolderregistryobserver.refresh(installedAddons))
                    installedfolderregistryobserver = (InstalledFolderRegistryObserver)iterator.next();

            }

            final InstalledAddon val$installedAddons[];

            
            {
                installedAddons = ainstalledaddon;
                super();
            }
        }
;
    }

    private static void initializeInstalledFolderRegistryObserversCollection()
    {
        if(installedFolderRegistryObservers == null)
            installedFolderRegistryObservers = ImplementorsCacheFactory.getInstance().getImplementors(com/mathworks/addons_common/notificationframework/InstalledFolderRegistryObserver);
    }

    private static final ExecutorService executorService = ThreadUtils.newSingleDaemonThreadExecutor(com/mathworks/addons_common/notificationframework/InstalledFolderRegistryObservers.getName());
    private static Collection installedFolderRegistryObservers = null;


}
