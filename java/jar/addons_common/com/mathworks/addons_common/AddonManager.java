// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   AddonManager.java

package com.mathworks.addons_common;

import com.mathworks.addons_common.notificationframework.AddOnInstallationObserver;
import java.io.IOException;

// Referenced classes of package com.mathworks.addons_common:
//            InstalledAddon, UpdateMetadata

public interface AddonManager
{

    public abstract boolean install(String as[], String s, String s1)
        throws IOException;

    public abstract void download(String as[], String s)
        throws IOException;

    public abstract boolean uninstall(String as[]);

    public abstract InstalledAddon[] getInstalled();

    public abstract String getAddonTypeServiced();

    public abstract void addAddOnInstallationObserver(AddOnInstallationObserver addoninstallationobserver);

    public abstract void installUpdateInAddOnManager(String s)
        throws Exception;

    public abstract void updateInAddOnManager(UpdateMetadata aupdatemetadata[]);
}
