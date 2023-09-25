// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   MLCommandHistoryServices.java

package com.mathworks.mlservices;


// Referenced classes of package com.mathworks.mlservices:
//            MLServices, MLCommandHistoryRegistrar, MLCommandHistory, MLServicesRegistry

public final class MLCommandHistoryServices extends MLServices
{

    public MLCommandHistoryServices()
    {
    }

    public static String[] getAllHistory()
    {
        registerCmdHistoryService();
        return sCmdHistory.getAllHistory();
    }

    public static String[] getSessionHistory()
    {
        registerCmdHistoryService();
        return sCmdHistory.getSessionHistory();
    }

    public static void removeAll()
    {
        registerCmdHistoryService();
        sCmdHistory.removeAll();
    }

    public static void save()
    {
        registerCmdHistoryService();
        sCmdHistory.save();
    }

    public static void add(String s)
    {
        registerCmdHistoryService();
        sCmdHistory.add(s);
    }

    private static void registerCmdHistoryService()
    {
        if(sCmdHistory == null)
            sCmdHistory = (MLCommandHistory)getRegisteredService(MLServicesRegistry.MLCOMMANDHISTORY_REGISTRAR, "getCommandHistory");
    }

    private static MLCommandHistory sCmdHistory;
}
