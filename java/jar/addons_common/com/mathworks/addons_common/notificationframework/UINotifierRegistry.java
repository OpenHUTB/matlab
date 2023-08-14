// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   UINotifierRegistry.java

package com.mathworks.addons_common.notificationframework;

import com.mathworks.addons_common.*;
import java.util.*;

// Referenced classes of package com.mathworks.addons_common.notificationframework:
//            UINotifier

public final class UINotifierRegistry
{
    public static final class UIServiced extends Enum
    {

        public static UIServiced[] values()
        {
            return (UIServiced[])$VALUES.clone();
        }

        public static UIServiced valueOf(String s)
        {
            return (UIServiced)Enum.valueOf(com/mathworks/addons_common/notificationframework/UINotifierRegistry$UIServiced, s);
        }

        public static final UIServiced ADDON_MANAGER;
        public static final UIServiced ADDON_EXPLORER;
        private static final UIServiced $VALUES[];

        static 
        {
            ADDON_MANAGER = new UIServiced("ADDON_MANAGER", 0);
            ADDON_EXPLORER = new UIServiced("ADDON_EXPLORER", 1);
            $VALUES = (new UIServiced[] {
                ADDON_MANAGER, ADDON_EXPLORER
            });
        }

        private UIServiced(String s, int i)
        {
            super(s, i);
        }
    }


    public UINotifierRegistry()
    {
    }

    public static synchronized void register(UINotifier uinotifier)
    {
        uiNotifierSet.add(uinotifier);
    }

    public static synchronized void unRegister(UINotifier uinotifier)
    {
        uiNotifierSet.remove(uinotifier);
    }

    public static void notifyInstalledToExplorer(Collection collection)
    {
        Iterator iterator = uiNotifierSet.iterator();
        do
        {
            if(!iterator.hasNext())
                break;
            UINotifier uinotifier = (UINotifier)iterator.next();
            if(uinotifier.getUIServiced().equals(UIServiced.ADDON_EXPLORER))
                uinotifier.notifyInstalled(collection);
        } while(true);
    }

    public static void notifyInstalledToManager(Collection collection)
    {
        Iterator iterator = uiNotifierSet.iterator();
        do
        {
            if(!iterator.hasNext())
                break;
            UINotifier uinotifier = (UINotifier)iterator.next();
            if(uinotifier.getUIServiced().equals(UIServiced.ADDON_MANAGER))
                uinotifier.notifyInstalled(collection);
        } while(true);
    }

    public static void notifyAddUpdate(UpdateMetadata updatemetadata)
    {
        UINotifier uinotifier;
        for(Iterator iterator = getNotificationObservers().iterator(); iterator.hasNext(); uinotifier.notifyAddUpdate(updatemetadata))
            uinotifier = (UINotifier)iterator.next();

    }

    public static void notifyRemoveUpdate(String s)
    {
        UINotifier uinotifier;
        for(Iterator iterator = getNotificationObservers().iterator(); iterator.hasNext(); uinotifier.notifyRemoveUpdate(s))
            uinotifier = (UINotifier)iterator.next();

    }

    public static void notifyRefreshUpdates(UpdateMetadata aupdatemetadata[])
    {
        UINotifier uinotifier;
        for(Iterator iterator = getNotificationObservers().iterator(); iterator.hasNext(); uinotifier.notifyRefreshUpdates(aupdatemetadata))
            uinotifier = (UINotifier)iterator.next();

    }

    public static void notifyAvailableUpdates(UpdateMetadata aupdatemetadata[])
    {
        UINotifier uinotifier;
        for(Iterator iterator = getNotificationObservers().iterator(); iterator.hasNext(); uinotifier.notifyAvailableUpdates(aupdatemetadata))
            uinotifier = (UINotifier)iterator.next();

    }

    private static synchronized Set getNotificationObservers()
    {
        return uiNotifierSet;
    }

    static void notifyInstalled(Collection collection)
    {
        UINotifier uinotifier;
        for(Iterator iterator = getNotificationObservers().iterator(); iterator.hasNext(); uinotifier.notifyInstalled(collection))
            uinotifier = (UINotifier)iterator.next();

    }

    static void notifyAdded(InstalledAddon installedaddon)
    {
        UINotifier uinotifier;
        for(Iterator iterator = getNotificationObservers().iterator(); iterator.hasNext(); uinotifier.notifyAdded(installedaddon))
            uinotifier = (UINotifier)iterator.next();

    }

    static void notifyRemoved(InstalledAddon installedaddon)
    {
        UINotifier uinotifier;
        for(Iterator iterator = getNotificationObservers().iterator(); iterator.hasNext(); uinotifier.notifyRemoved(installedaddon))
            uinotifier = (UINotifier)iterator.next();

    }

    static void notifyRefreshed(Collection collection)
    {
        UINotifier uinotifier;
        for(Iterator iterator = getNotificationObservers().iterator(); iterator.hasNext(); uinotifier.notifyRefreshed(collection))
            uinotifier = (UINotifier)iterator.next();

    }

    static void notifyUpdated(InstalledAddon installedaddon)
    {
        UINotifier uinotifier;
        for(Iterator iterator = getNotificationObservers().iterator(); iterator.hasNext(); uinotifier.notifyUpdated(installedaddon))
            uinotifier = (UINotifier)iterator.next();

    }

    static void notifyInstallFailed(String s, String s1)
    {
        UINotifier uinotifier;
        for(Iterator iterator = getNotificationObservers().iterator(); iterator.hasNext(); uinotifier.notifyInstallFailed(s, s1))
            uinotifier = (UINotifier)iterator.next();

    }

    static void notifyUninstallFailed(String s, String s1)
    {
        UINotifier uinotifier;
        for(Iterator iterator = getNotificationObservers().iterator(); iterator.hasNext(); uinotifier.notifyUninstallFailed(s, s1))
            uinotifier = (UINotifier)iterator.next();

    }

    static void showUninstallInformationDialog(InstalledAddon installedaddon, String s)
    {
        UINotifier uinotifier;
        for(Iterator iterator = getNotificationObservers().iterator(); iterator.hasNext(); uinotifier.showUninstallInformationDialog(installedaddon, s))
            uinotifier = (UINotifier)iterator.next();

    }

    static void openUrl(OpenUrlMessage openurlmessage)
    {
        UINotifier uinotifier;
        for(Iterator iterator = getNotificationObservers().iterator(); iterator.hasNext(); uinotifier.openUrl(openurlmessage))
            uinotifier = (UINotifier)iterator.next();

    }

    private static Set uiNotifierSet = new HashSet();

}
