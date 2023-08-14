// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   MessageFromClient.java

package com.mathworks.addons_common.matlabonline;


public class MessageFromClient extends Enum
{

    public static MessageFromClient[] values()
    {
        return (MessageFromClient[])$VALUES.clone();
    }

    public static MessageFromClient valueOf(String s)
    {
        return (MessageFromClient)Enum.valueOf(com/mathworks/addons_common/matlabonline/MessageFromClient, s);
    }

    private MessageFromClient(String s, int i)
    {
        super(s, i);
    }

    static MessageFromClient getMatch(String s)
    {
        MessageFromClient amessagefromclient[] = values();
        int i = amessagefromclient.length;
        for(int j = 0; j < i; j++)
        {
            MessageFromClient messagefromclient = amessagefromclient[j];
            if(messagefromclient.toString().equals(s))
                return messagefromclient;
        }

        throw new UnsupportedOperationException((new StringBuilder()).append("Unsupported message from MATLAB Online ").append(s).toString());
    }


    public static final MessageFromClient OPEN_APPS_VIEW_IN_EXPLORER;
    public static final MessageFromClient MANAGER_WINDOW_STATE;
    public static final MessageFromClient OPEN_RESOLVED_INSTALLER_URL_IN_MANAGER;
    public static final MessageFromClient OPEN_EXPLORER_WITH_RESOLVED_URL;
    public static final MessageFromClient SHOW_RESOLVED_URL_IN_EXPLORER;
    private static final MessageFromClient $VALUES[];

    static 
    {
        OPEN_APPS_VIEW_IN_EXPLORER = new MessageFromClient("OPEN_APPS_VIEW_IN_EXPLORER", 0) {

            public String toString()
            {
                return "openAppsViewInExplorer";
            }

        }
;
        MANAGER_WINDOW_STATE = new MessageFromClient("MANAGER_WINDOW_STATE", 1) {

            public String toString()
            {
                return "managerWindowState";
            }

        }
;
        OPEN_RESOLVED_INSTALLER_URL_IN_MANAGER = new MessageFromClient("OPEN_RESOLVED_INSTALLER_URL_IN_MANAGER", 2) {

            public String toString()
            {
                return "openResolvedInstallerUrlInManager";
            }

        }
;
        OPEN_EXPLORER_WITH_RESOLVED_URL = new MessageFromClient("OPEN_EXPLORER_WITH_RESOLVED_URL", 3) {

            public String toString()
            {
                return "openExplorerWithResolvedUrl";
            }

        }
;
        SHOW_RESOLVED_URL_IN_EXPLORER = new MessageFromClient("SHOW_RESOLVED_URL_IN_EXPLORER", 4) {

            public String toString()
            {
                return "showResolvedUrlInExplorer";
            }

        }
;
        $VALUES = (new MessageFromClient[] {
            OPEN_APPS_VIEW_IN_EXPLORER, MANAGER_WINDOW_STATE, OPEN_RESOLVED_INSTALLER_URL_IN_MANAGER, OPEN_EXPLORER_WITH_RESOLVED_URL, SHOW_RESOLVED_URL_IN_EXPLORER
        });
    }
}
