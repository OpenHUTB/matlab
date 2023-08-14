// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   InstallLocation.java

package com.mathworks.addons_common.util.settings;

import com.mathworks.addons_common.notificationframework.EnableDisableManagementNotifier;
import com.mathworks.addons_common.notificationframework.InstalledAddOnsCache;
import com.mathworks.addons_common.util.FolderNameUtils;
import com.mathworks.addons_common.util.MatlabPlatformUtil;
import com.mathworks.mvm.exec.MvmExecutionException;
import com.mathworks.services.settings.*;
import com.mathworks.util.Log;
import com.mathworks.util.ThreadUtils;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.concurrent.ExecutorService;

// Referenced classes of package com.mathworks.addons_common.util.settings:
//            InstallLocationUtil, InstallationFolderUtils

public final class InstallLocation
{
    private static class LazyHolder
    {

        private static final InstallLocation INSTANCE = new InstallLocation();



        private LazyHolder()
        {
        }
    }


    InstallLocation()
    {
        installationRoot = null;
        registrationRoot = null;
        hasRegistrationRoot = false;
        if(MatlabPlatformUtil.isMatlabOnline())
        {
            installationRoot = Paths.get("/.Add-Ons", new String[0]);
            registrationRoot = Paths.get("/MATLAB Add-Ons", new String[0]);
            hasRegistrationRoot = true;
        } else
        {
            initInstallationFolderSettingsListener();
        }
    }

    static synchronized InstallLocation getInstance()
    {
        return LazyHolder.INSTANCE;
    }

    void setInstallationRoot(Path path)
    {
        boolean flag = InstallLocationUtil.mustCacheBeUpdated(installationRoot, path, getDefaultInstallationFolder());
        installationRoot = path;
        if(flag)
            updateCache();
    }

    private void updateCache()
    {
        ExecutorService executorservice = ThreadUtils.newSingleDaemonThreadExecutor((new StringBuilder()).append(com/mathworks/addons_common/util/settings/InstallLocation.getName()).append(" Update cache").toString());
        executorservice.submit(new Runnable() {

            public void run()
            {
                com.mathworks.addons_common.InstalledAddon ainstalledaddon[] = InstalledAddOnsCache.getInstance().getInstalledAddonsAsArray();
                com.mathworks.addons_common.InstalledAddon ainstalledaddon1[] = ainstalledaddon;
                int i = ainstalledaddon1.length;
                for(int j = 0; j < i; j++)
                {
                    com.mathworks.addons_common.InstalledAddon installedaddon = ainstalledaddon1[j];
                    EnableDisableManagementNotifier.notifyToDisable(installedaddon);
                }

                InstalledAddOnsCache.getInstance().refreshCacheAndClearPersistenceData();
            }

            final InstallLocation this$0;

            
            {
                this$0 = InstallLocation.this;
                super();
            }
        }
);
        executorservice.shutdown();
    }

    void setRegistrationRoot(Path path)
    {
        hasRegistrationRoot = true;
        registrationRoot = path;
    }

    Path getFolderToRegister()
        throws InterruptedException, SettingTypeException, SettingNotFoundException, MvmExecutionException
    {
        if(hasRegistrationRoot)
            return registrationRoot;
        else
            return getFolderToInstall();
    }

    private void resetFolderToInstall()
    {
        setInstallationRoot(null);
    }

    Path getFolderToInstall()
        throws SettingNotFoundException, SettingTypeException, MvmExecutionException, InterruptedException
    {
        if(installationRoot != null)
            return installationRoot;
        if(!InstallationFolderUtils.isSettingEmpty())
        {
            initializeFolderToInstall();
            return installationRoot;
        } else
        {
            return getDefaultInstallationFolder();
        }
    }

    void initializeFolderToInstall()
        throws SettingNotFoundException, SettingTypeException
    {
        installationRoot = getInstallationFolderFromSetting();
    }

    public static Path getInstallationRoot()
        throws InterruptedException, SettingTypeException, SettingNotFoundException, MvmExecutionException
    {
        return getInstance().getFolderToInstall();
    }

    public static Path getRegistrationRoot()
        throws InterruptedException, SettingTypeException, SettingNotFoundException, MvmExecutionException
    {
        return getInstance().getFolderToRegister();
    }

    Path getDefaultInstallationFolder()
    {
        return FolderNameUtils.getDefaultAddonInstallLocation();
    }

    private void initInstallationFolderSettingsListener()
    {
        SettingAdapter settingadapter = new SettingAdapter() {

            public void settingChanged(SettingChangeEvent settingchangeevent)
            {
                settingChangedHandler();
            }

            final InstallLocation this$0;

            
            {
                this$0 = InstallLocation.this;
                super();
            }
        }
;
        addInstallationFolderSettingListener(settingadapter);
    }

    private void settingChangedHandler()
    {
        try
        {
            if(InstallationFolderUtils.isSettingEmpty())
                resetFolderToInstall();
            else
                setInstallationRoot(getInstallationFolderFromSetting());
        }
        catch(Object obj)
        {
            Log.logException(((Exception) (obj)));
        }
    }

    private void addInstallationFolderSettingListener(SettingListener settinglistener)
    {
        try
        {
            InstallationFolderUtils.getInstallationFolderSetting().addListener(settinglistener);
        }
        catch(Exception exception) { }
    }

    private Path getInstallationFolderFromSetting()
        throws SettingNotFoundException, SettingTypeException
    {
        Setting setting = InstallationFolderUtils.getInstallationFolderSetting();
        Path path = Paths.get((String)setting.get(), new String[0]);
        return path.toAbsolutePath();
    }

    private static final String INSTALLATION_ROOT = "/.Add-Ons";
    private static final String REGISTRATION_ROOT = "/MATLAB Add-Ons";
    private volatile Path installationRoot;
    private Path registrationRoot;
    private boolean hasRegistrationRoot;

}
