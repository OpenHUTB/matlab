// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   MatlabDesktopServices.java

package com.mathworks.mlservices;

import com.mathworks.widgets.desk.Desktop;

// Referenced classes of package com.mathworks.mlservices:
//            MLServices, MatlabDesktopRegistrar, MatlabDesktop, MLServicesRegistry

public final class MatlabDesktopServices extends MLServices
{

    public MatlabDesktopServices()
    {
    }

    public static Desktop getDesktop()
    {
        if(sDesktop instanceof Desktop)
            return (Desktop)sDesktop;
        else
            return null;
    }

    public static void showCommandWindow()
    {
        sDesktop.showCommandWindow();
    }

    public static void showCommandHistory()
    {
        sDesktop.showCommandHistory();
    }

    public static void showFileBrowser()
    {
        sDesktop.showFileBrowser();
    }

    public static void showWorkspaceBrowser()
    {
        sDesktop.showWorkspaceBrowser();
    }

    public static void showHelpBrowser()
    {
        sDesktop.showHelpBrowser();
    }

    public static void showProfiler()
    {
        sDesktop.showProfiler();
    }

    public static void closeCommandWindow()
    {
        sDesktop.closeCommandWindow();
    }

    public static void closeCommandHistory()
    {
        sDesktop.closeCommandHistory();
    }

    public static void closeFileBrowser()
    {
        sDesktop.closeFileBrowser();
    }

    public static void closeWorkspaceBrowser()
    {
        sDesktop.closeWorkspaceBrowser();
    }

    public static void closeHelpBrowser()
    {
        sDesktop.closeHelpBrowser();
    }

    public static void closeProfiler()
    {
        sDesktop.closeProfiler();
    }

    public static void setDefaultLayout()
    {
        sDesktop.setDefaultLayout();
    }

    public static void setCommandOnlyLayout()
    {
        sDesktop.setCommandOnlyLayout();
    }

    public static void setCommandAndHistoryLayout()
    {
        sDesktop.setCommandAndHistoryLayout();
    }

    private static MatlabDesktop sDesktop;

    static 
    {
        sDesktop = (MatlabDesktop)getRegisteredService(MLServicesRegistry.MATLABDESKTOP_REGISTRAR, "getDesktop");
    }
}
