// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   AddOnInstallationObserverImpl.java

package com.mathworks.addons_common.notificationframework;

import com.mathworks.addons_common.InstalledAddon;
import com.mathworks.addons_common.OpenUrlMessage;
import com.mathworks.util.ThreadUtils;
import java.nio.file.Path;
import java.util.concurrent.ExecutorService;

// Referenced classes of package com.mathworks.addons_common.notificationframework:
//            AddOnInstallationObserver, UINotifierRegistry, InstalledAddOnsCache, AddOnManagementRegistrationFrameworkAdapter, 
//            AddonManagement

public final class AddOnInstallationObserverImpl
    implements AddOnInstallationObserver
{

    public AddOnInstallationObserverImpl()
    {
    }

    public void notifyInstalled(final InstalledAddon installedAddon)
    {
        executorService.submit(new Runnable() {

            public void run()
            {
                InstalledAddOnsCache.getInstance().add(installedAddon);
                AddOnManagementRegistrationFrameworkAdapter.addSupportPackage(installedAddon.getIdentifier(), installedAddon.getVersion());
            }

            final InstalledAddon val$installedAddon;
            final AddOnInstallationObserverImpl this$0;

            
            {
                this$0 = AddOnInstallationObserverImpl.this;
                installedAddon = installedaddon;
                super();
            }
        }
);
    }

    public void notifyInstalled(final InstalledAddon installedAddon, final Path installedFolder)
    {
        executorService.submit(new Runnable() {

            public void run()
            {
                AddonManagement.addFolder(installedFolder, installedAddon);
            }

            final Path val$installedFolder;
            final InstalledAddon val$installedAddon;
            final AddOnInstallationObserverImpl this$0;

            
            {
                this$0 = AddOnInstallationObserverImpl.this;
                installedFolder = path;
                installedAddon = installedaddon;
                super();
            }
        }
);
    }

    public void notifyUninstalled(final InstalledAddon installedAddon)
    {
        executorService.submit(new Runnable() {

            public void run()
            {
                AddonManagement.removeFolder(installedAddon.getInstalledFolder(), installedAddon);
                AddOnManagementRegistrationFrameworkAdapter.removeSupportPackage(installedAddon.getIdentifier(), installedAddon.getVersion());
            }

            final InstalledAddon val$installedAddon;
            final AddOnInstallationObserverImpl this$0;

            
            {
                this$0 = AddOnInstallationObserverImpl.this;
                installedAddon = installedaddon;
                super();
            }
        }
);
    }

    public void notifyUpdated(final InstalledAddon installedAddon)
    {
        executorService.submit(new Runnable() {

            public void run()
            {
                InstalledAddOnsCache.getInstance().update(installedAddon);
                if(installedAddon.getType().equals("product"))
                    AddOnManagementRegistrationFrameworkAdapter.updateMathWorksProduct(installedAddon.getIdentifier(), installedAddon.getVersion());
                else
                if(!installedAddon.getType().equals("support_package"))
                    AddOnManagementRegistrationFrameworkAdapter.updateAddOn(installedAddon.getIdentifier(), installedAddon.getVersion(), installedAddon.isEnabled());
            }

            final InstalledAddon val$installedAddon;
            final AddOnInstallationObserverImpl this$0;

            
            {
                this$0 = AddOnInstallationObserverImpl.this;
                installedAddon = installedaddon;
                super();
            }
        }
);
    }

    public void notifyUninstalled(InstalledAddon installedaddon, String s)
    {
        notifyUninstalled(installedaddon);
        UINotifierRegistry.showUninstallInformationDialog(installedaddon, s);
    }

    public void notifyInstallFailed(String s, String s1)
    {
        UINotifierRegistry.notifyInstallFailed(s, s1);
    }

    public void notifyUninstallFailed(String s, String s1)
    {
        UINotifierRegistry.notifyUninstallFailed(s, s1);
    }

    /**
     * @deprecated Method openUrl is deprecated
     */

    public void openUrl(OpenUrlMessage openurlmessage)
    {
        UINotifierRegistry.openUrl(openurlmessage);
    }

    private static final ExecutorService executorService = ThreadUtils.newSingleDaemonThreadExecutor("Installation Observer");

}
