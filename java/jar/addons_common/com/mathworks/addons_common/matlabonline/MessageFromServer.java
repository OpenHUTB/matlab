// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   MessageFromServer.java

package com.mathworks.addons_common.matlabonline;


public class MessageFromServer extends Enum
{

    public static MessageFromServer[] values()
    {
        return (MessageFromServer[])$VALUES.clone();
    }

    public static MessageFromServer valueOf(String s)
    {
        return (MessageFromServer)Enum.valueOf(com/mathworks/addons_common/matlabonline/MessageFromServer, s);
    }

    private MessageFromServer(String s, int i)
    {
        super(s, i);
    }


    public static final MessageFromServer REFRESH_OPEN_FOLDERS;
    public static final MessageFromServer SHOW_SAVE_TO_MATLAB_DRIVE_DIALOG;
    public static final MessageFromServer SHOW_BALLOON_TOOLTIP_NOTIFICATION;
    public static final MessageFromServer OPEN_URL_IN_SYSTEM_BROWSER;
    public static final MessageFromServer RESOLVE_INSTALLER_URL_AND_OPEN_IN_MANAGER;
    private static final MessageFromServer $VALUES[];

    static 
    {
        REFRESH_OPEN_FOLDERS = new MessageFromServer("REFRESH_OPEN_FOLDERS", 0) {

            public String toString()
            {
                return "refreshOpenFolders";
            }

        }
;
        SHOW_SAVE_TO_MATLAB_DRIVE_DIALOG = new MessageFromServer("SHOW_SAVE_TO_MATLAB_DRIVE_DIALOG", 1) {

            public String toString()
            {
                return "showSaveToMatlabDriveDialog";
            }

        }
;
        SHOW_BALLOON_TOOLTIP_NOTIFICATION = new MessageFromServer("SHOW_BALLOON_TOOLTIP_NOTIFICATION", 2) {

            public String toString()
            {
                return "showBalloonTooltipNotification";
            }

        }
;
        OPEN_URL_IN_SYSTEM_BROWSER = new MessageFromServer("OPEN_URL_IN_SYSTEM_BROWSER", 3) {

            public String toString()
            {
                return "openInSystemBrowser";
            }

        }
;
        RESOLVE_INSTALLER_URL_AND_OPEN_IN_MANAGER = new MessageFromServer("RESOLVE_INSTALLER_URL_AND_OPEN_IN_MANAGER", 4) {

            public String toString()
            {
                return "resolveInstallerUrlAndOpenInManager";
            }

        }
;
        $VALUES = (new MessageFromServer[] {
            REFRESH_OPEN_FOLDERS, SHOW_SAVE_TO_MATLAB_DRIVE_DIALOG, SHOW_BALLOON_TOOLTIP_NOTIFICATION, OPEN_URL_IN_SYSTEM_BROWSER, RESOLVE_INSTALLER_URL_AND_OPEN_IN_MANAGER
        });
    }
}
