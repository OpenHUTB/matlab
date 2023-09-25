// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   MLPrefsDialogServices.java

package com.mathworks.mlservices;

import java.io.PrintStream;

// Referenced classes of package com.mathworks.mlservices:
//            MLServices, MLPrefsDialogRegistrar, MLPrefsDialog, MLServicesRegistry

public class MLPrefsDialogServices extends MLServices
{
    private static class ServicesRegistryListener
        implements MLServicesRegistry.Listener
    {

        public void registrationChanged(String s)
        {
            if(s.equals("getMLPrefsDialog"))
                MLPrefsDialogServices.sMLPrefsDialog = null;
        }

        private ServicesRegistryListener()
        {
        }

    }


    private MLPrefsDialogServices()
    {
    }

    public static void showPrefsDialog()
    {
        loadMLPrefsDialogService();
        if(sMLPrefsDialog != null)
            sMLPrefsDialog.showPrefsDialog();
    }

    public static void showPrefsDialog(String s)
    {
        loadMLPrefsDialogService();
        if(sMLPrefsDialog != null)
            sMLPrefsDialog.showPrefsDialog(s);
    }

    public static void showLastPrefsDialog(String s)
    {
        loadMLPrefsDialogService();
        if(sMLPrefsDialog != null)
            sMLPrefsDialog.showLastPrefsDialog(s);
    }

    public static void registerPanel(String s, String s1)
    {
        loadMLPrefsDialogService();
        if(sMLPrefsDialog != null)
            try
            {
                sMLPrefsDialog.registerPanel(s, s1, false);
            }
            catch(ClassNotFoundException classnotfoundexception)
            {
                throw new IllegalArgumentException(classnotfoundexception);
            }
    }

    public static void unregisterPanel(String s, String s1)
    {
        loadMLPrefsDialogService();
        if(sMLPrefsDialog != null)
            sMLPrefsDialog.unregisterPanel(s, s1);
    }

    private static void loadMLPrefsDialogService()
    {
        if(sMLPrefsDialog == null)
        {
            sMLPrefsDialog = (MLPrefsDialog)getRegisteredService(MLServicesRegistry.MLPREFSDIALOG_REGISTRAR, "getMLPrefsDialog");
            if(sMLPrefsDialog == null)
                System.err.println("MLPrefsDialogServices: there is no registered Preferences Dialog service.");
        }
    }

    private static MLPrefsDialog sMLPrefsDialog;

    static 
    {
        MLServicesRegistry.addRegistrationListener(new ServicesRegistryListener());
    }

}
