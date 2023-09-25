// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   MLWorkspaceServices.java

package com.mathworks.mlservices;

import javax.swing.event.ChangeListener;

// Referenced classes of package com.mathworks.mlservices:
//            MLServices, MLWorkspaceRegistrar, MLWorkspace, MLServicesRegistry

public final class MLWorkspaceServices extends MLServices
{

    public MLWorkspaceServices()
    {
    }

    public static void invoke()
    {
        MLWorkspace mlworkspace = getRegisteredService();
        if(mlworkspace != null)
            sWorkspace.invoke();
    }

    public static String[] getSelectedNames()
    {
        MLWorkspace mlworkspace = getRegisteredService();
        if(mlworkspace != null)
            return sWorkspace.getSelectedNames();
        else
            return ESA;
    }

    public static void setSelectedNames(String as[])
    {
        MLWorkspace mlworkspace = getRegisteredService();
        if(mlworkspace != null)
            sWorkspace.setSelectedNames(as);
    }

    public static String[] getSelectedSizes()
    {
        MLWorkspace mlworkspace = getRegisteredService();
        if(mlworkspace != null)
            return sWorkspace.getSelectedSizes();
        else
            return ESA;
    }

    public static String[] getSelectedClasses()
    {
        MLWorkspace mlworkspace = getRegisteredService();
        if(mlworkspace != null)
            return sWorkspace.getSelectedClasses();
        else
            return ESA;
    }

    public static void addChronSelectionChangeListener(ChangeListener changelistener)
    {
        MLWorkspace mlworkspace = getRegisteredService();
        if(mlworkspace != null)
            sWorkspace.addChronSelectionChangeListener(changelistener);
    }

    public static void removeChronSelectionChangeListener(ChangeListener changelistener)
    {
        MLWorkspace mlworkspace = getRegisteredService();
        if(mlworkspace != null)
            sWorkspace.removeChronSelectionChangeListener(changelistener);
    }

    private static MLWorkspace getRegisteredService()
    {
        if(sWorkspace == null)
            sWorkspace = (MLWorkspace)getRegisteredService(MLServicesRegistry.MLWORKSPACE_REGISTRAR, "getWorkspace");
        return sWorkspace;
    }

    private static MLWorkspace sWorkspace;
    private static final String ESA[] = new String[0];

}
