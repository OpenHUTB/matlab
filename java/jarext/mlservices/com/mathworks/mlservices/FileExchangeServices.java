// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   FileExchangeServices.java

package com.mathworks.mlservices;


// Referenced classes of package com.mathworks.mlservices:
//            MLServices, FileExchangeRegistrar, FileExchange, MLServicesRegistry

public class FileExchangeServices extends MLServices
{

    public FileExchangeServices()
    {
    }

    public static void search(String s)
    {
        sFileExchange.search(s);
    }

    private static FileExchange sFileExchange;

    static 
    {
        sFileExchange = (FileExchange)getRegisteredService(MLServicesRegistry.FILEEXCHANGE_REGISTRAR, "getFileExchange");
    }
}
