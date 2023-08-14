// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   UINotifier.java

package com.mathworks.addons_common.notificationframework;

import com.mathworks.addons_common.*;
import java.util.Collection;

// Referenced classes of package com.mathworks.addons_common.notificationframework:
//            UINotifierRegistry

public interface UINotifier
{

    public abstract UINotifierRegistry.UIServiced getUIServiced();

    public abstract void notifyInstalled(Collection collection);

    public abstract void notifyAdded(InstalledAddon installedaddon);

    public abstract void notifyRemoved(InstalledAddon installedaddon);

    public abstract void notifyUpdated(InstalledAddon installedaddon);

    public abstract void notifyRefreshed(Collection collection);

    public abstract void showUninstallInformationDialog(InstalledAddon installedaddon, String s);

    public abstract void notifyInstallFailed(String s, String s1);

    public abstract void notifyUninstallFailed(String s, String s1);

    /**
     * @deprecated Method openUrl is deprecated
     */

    public abstract void openUrl(OpenUrlMessage openurlmessage);

    public abstract void notifyAddUpdate(UpdateMetadata updatemetadata);

    public abstract void notifyRemoveUpdate(String s);

    public abstract void notifyRefreshUpdates(UpdateMetadata aupdatemetadata[]);

    public abstract void notifyAvailableUpdates(UpdateMetadata aupdatemetadata[]);
}
