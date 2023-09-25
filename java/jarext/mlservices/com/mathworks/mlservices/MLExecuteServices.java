// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   MLExecuteServices.java

package com.mathworks.mlservices;

import com.mathworks.jmi.Matlab;
import java.util.Enumeration;
import java.util.Vector;

// Referenced classes of package com.mathworks.mlservices:
//            MLServices, MLExecuteRegistrar, MLExecute, MLExecutionListener, 
//            MLServicesRegistry, MatlabExecutionErrorHandler

public class MLExecuteServices extends MLServices
{
    private static class ServicesRegistryListener
        implements MLServicesRegistry.Listener
    {

        public void registrationChanged(String s)
        {
            if(s.equals("getMLExecute"))
                MLExecuteServices.sMLExecute = null;
        }

        private ServicesRegistryListener()
        {
        }

    }


    private MLExecuteServices()
    {
    }

    public static void executeCommand(String s)
    {
        loadMLExecuteCommandService();
        if(sMLExecute != null)
            sMLExecute.executeCommand(s);
        else
            sMatlab.evalConsoleOutput(s);
    }

    public static void executeCommand(String s, MatlabExecutionErrorHandler matlabexecutionerrorhandler)
    {
        loadMLExecuteCommandService();
        if(sMLExecute != null)
            sMLExecute.executeCommand(s, matlabexecutionerrorhandler);
        else
            sMatlab.evalConsoleOutput(s);
    }

    public static void consoleEval(String s)
    {
        loadMLExecuteCommandService();
        if(sMLExecute != null)
            sMLExecute.consoleEval(s);
        else
            sMatlab.evalStreamOutput(s, null);
    }

    public static void consoleEval(String s, int i)
    {
        loadMLExecuteCommandService();
        if(sMLExecute != null)
            sMLExecute.consoleEval(s, i);
        else
            sMatlab.evalStreamOutput(s, null, i);
    }

    public static synchronized void addMLExecutionListener(MLExecutionListener mlexecutionlistener)
    {
        loadMLExecuteCommandService();
        if(sMLExecute != null)
            sMLExecute.addMLExecutionListener(mlexecutionlistener);
        else
            sListenersToAdd.add(mlexecutionlistener);
    }

    public static void removeMLExecutionListener(MLExecutionListener mlexecutionlistener)
    {
        loadMLExecuteCommandService();
        if(sMLExecute != null)
            sMLExecute.removeMLExecutionListener(mlexecutionlistener);
        else
            sListenersToAdd.remove(mlexecutionlistener);
    }

    public static synchronized boolean isCommandServiceLoaded()
    {
        return sMLExecute != null;
    }

    private static synchronized void loadMLExecuteCommandService()
    {
        if(sMLExecute == null)
        {
            sMLExecute = (MLExecute)getRegisteredService(MLServicesRegistry.MLEXECUTE_REGISTRAR, "getMLExecute");
            if(sMLExecute != null)
            {
                for(Enumeration enumeration = sListenersToAdd.elements(); enumeration.hasMoreElements(); addMLExecutionListener((MLExecutionListener)enumeration.nextElement()));
            }
        }
    }

    private static MLExecute sMLExecute;
    private static Matlab sMatlab = new Matlab();
    private static Vector sListenersToAdd = new Vector();

    static 
    {
        MLServicesRegistry.addRegistrationListener(new ServicesRegistryListener());
    }

}
