// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   MLCommandWindowServices.java

package com.mathworks.mlservices;


// Referenced classes of package com.mathworks.mlservices:
//            MLServices, MLCommandWindowRegistrar, MLCommandWindow, MLServicesRegistry

public class MLCommandWindowServices extends MLServices
{
    private static class ServicesRegistryListener
        implements MLServicesRegistry.Listener
    {

        public void registrationChanged(String s)
        {
            if(s.equals("getMLCommandWindow"))
                MLCommandWindowServices.sMLCommandWindow = null;
        }

        private ServicesRegistryListener()
        {
        }

    }


    private MLCommandWindowServices()
    {
    }

    public static boolean hasFocus()
    {
        loadMLCommandWindowService();
        if(sMLCommandWindow != null)
            return sMLCommandWindow.hasFocus();
        else
            return false;
    }

    public static boolean isJavaCWInitialized()
    {
        loadMLCommandWindowService();
        if(sMLCommandWindow != null)
            return sMLCommandWindow.isJavaCWInitialized();
        else
            return false;
    }

    private static synchronized void loadMLCommandWindowService()
    {
        if(sMLCommandWindow == null)
            sMLCommandWindow = (MLCommandWindow)getRegisteredService(MLServicesRegistry.MLCOMMANDWINDOW_REGISTRAR, "getMLCommandWindow");
    }

    private static MLCommandWindow sMLCommandWindow;

    static 
    {
        MLServicesRegistry.addRegistrationListener(new ServicesRegistryListener());
    }

}
