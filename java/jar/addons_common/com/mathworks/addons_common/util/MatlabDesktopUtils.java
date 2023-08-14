// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   MatlabDesktopUtils.java

package com.mathworks.addons_common.util;

import com.mathworks.addons_common.matlabonline.AddOnsWindowState;
import com.mathworks.mlservices.MatlabDesktopServices;
import com.mathworks.mvm.MVM;
import com.mathworks.mvm.context.MvmContext;
import com.mathworks.mvm.exec.FutureFevalResult;
import com.mathworks.mvm.exec.MvmExecutionException;
import com.mathworks.util.NativeJava;
import com.mathworks.util.PlatformInfo;
import com.mathworks.widgets.desk.DTFrame;
import com.mathworks.widgets.desk.Desktop;
import javax.swing.SwingUtilities;

// Referenced classes of package com.mathworks.addons_common.util:
//            MatlabPlatformUtil

public final class MatlabDesktopUtils
{

    private MatlabDesktopUtils()
    {
    }

    public static DTFrame getMatlabDesktopFrame()
    {
        Desktop desktop = MatlabDesktopServices.getDesktop();
        return desktop != null ? desktop.getMainFrame() : null;
    }

    public static boolean isManagerOpen()
        throws MvmExecutionException, InterruptedException
    {
        if(MatlabPlatformUtil.isMatlabOnline())
            return AddOnsWindowState.isManagerOpen();
        else
            return ((Boolean)evalCommandWithReturnValue("matlab.internal.addons.Manager.getInstance.windowExists")).booleanValue();
    }

    public static boolean isExplorerOpen()
        throws MvmExecutionException, InterruptedException
    {
        if(MatlabPlatformUtil.isMatlabOnline())
            return AddOnsWindowState.isExplorerOpen();
        else
            return ((Boolean)evalCommandWithReturnValue("matlab.internal.addons.Explorer.getInstance.windowExists")).booleanValue();
    }

    public static void bringMatlabToFront()
    {
        SwingUtilities.invokeLater(new Runnable() {

            public void run()
            {
                Desktop desktop = MatlabDesktopServices.getDesktop();
                if(desktop == null)
                    return;
                if(PlatformInfo.isMacintosh())
                {
                    NativeJava.macActivateIgnoringOtherApps();
                } else
                {
                    DTFrame dtframe = desktop.getMainFrame();
                    if(dtframe == null)
                        return;
                    dtframe.toFront();
                }
                desktop.setClientSelected("Current Directory", true);
            }

        }
);
    }

    private static Object evalCommandWithReturnValue(String s)
        throws MvmExecutionException, InterruptedException
    {
        FutureFevalResult futurefevalresult = MvmContext.get().feval("eval", (Object[])(new String[] {
            s
        }));
        return futurefevalresult.get();
    }

    private static final String MANAGER_EXISTS_COMMAND = "matlab.internal.addons.Manager.getInstance.windowExists";
    private static final String EXPLORER_EXISTS_COMMAND = "matlab.internal.addons.Explorer.getInstance.windowExists";
}
