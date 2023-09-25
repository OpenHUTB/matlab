// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   MLServicesRegistry.java

package com.mathworks.mlservices;

import java.lang.reflect.Constructor;
import java.util.EventListener;

// Referenced classes of package com.mathworks.mlservices:
//            MLExecuteRegistrar, MLPrefsDialogRegistrar

public class MLServicesRegistry
{
    private static class EventMulticaster
        implements EventListener
    {

        protected EventListener remove(EventListener eventlistener)
        {
            if(eventlistener == a)
                return b;
            if(eventlistener == b)
                return a;
            EventListener eventlistener1 = remove(a, eventlistener);
            EventListener eventlistener2 = remove(b, eventlistener);
            if(eventlistener1 == a && eventlistener2 == b)
                return this;
            else
                return add(eventlistener1, eventlistener2);
        }

        protected static EventListener add(EventListener eventlistener, EventListener eventlistener1)
        {
            return add(eventlistener, eventlistener1, com/mathworks/mlservices/MLServicesRegistry$EventMulticaster);
        }

        protected static EventListener add(EventListener eventlistener, EventListener eventlistener1, Class class1)
        {
            if(eventlistener == null)
                return eventlistener1;
            if(eventlistener1 == null)
                return eventlistener;
            try
            {
                Object aobj[] = {
                    eventlistener, eventlistener1
                };
                return (EventListener)class1.getDeclaredConstructor(params).newInstance(aobj);
            }
            catch(Exception exception)
            {
                exception.printStackTrace();
            }
            return null;
        }

        protected static EventListener remove(EventListener eventlistener, EventListener eventlistener1)
        {
            if(eventlistener == eventlistener1 || eventlistener == null)
                return null;
            if(eventlistener instanceof EventMulticaster)
                return ((EventMulticaster)eventlistener).remove(eventlistener1);
            else
                return eventlistener;
        }

        private static final Class params[] = {
            java/util/EventListener, java/util/EventListener
        };
        protected final EventListener a;
        protected final EventListener b;


        private EventMulticaster()
        {
            a = null;
            b = null;
        }

        protected EventMulticaster(EventListener eventlistener, EventListener eventlistener1)
        {
            a = eventlistener;
            b = eventlistener1;
        }
    }

    private static class SRMulticaster extends EventMulticaster
        implements Listener
    {

        protected static EventListener add(EventListener eventlistener, EventListener eventlistener1)
        {
            return add(eventlistener, eventlistener1, com/mathworks/mlservices/MLServicesRegistry$SRMulticaster);
        }

        public void registrationChanged(String s)
        {
            ((Listener)a).registrationChanged(s);
            ((Listener)b).registrationChanged(s);
        }

        protected SRMulticaster(EventListener eventlistener, EventListener eventlistener1)
        {
            super(eventlistener, eventlistener1);
        }
    }

    static interface Listener
        extends EventListener
    {

        public abstract void registrationChanged(String s);
    }


    private MLServicesRegistry()
    {
    }

    public static void registerMLExecuteRegistrar(String s)
    {
        MLEXECUTE_REGISTRAR = s;
        notifyListeners("getMLExecute");
    }

    public static void registerMLPrefsDialogRegistrar(String s)
    {
        MLPREFSDIALOG_REGISTRAR = s;
        notifyListeners("getMLPrefsDialog");
    }

    static synchronized void addRegistrationListener(Listener listener)
    {
        sListener = (Listener)SRMulticaster.add(sListener, listener);
    }

    static synchronized void removeRegistrationListener(Listener listener)
    {
        sListener = (Listener)SRMulticaster.remove(sListener, listener);
    }

    private static void notifyListeners(String s)
    {
        if(sListener != null)
            sListener.registrationChanged(s);
    }

    static String MLEXECUTE_REGISTRAR = "com.mathworks.mde.cmdwin.CmdWinExecuteServices";
    static String MLPREFSDIALOG_REGISTRAR = "com.mathworks.mlwidgets.prefs.PrefsDialogRegistrar";
    static String MLHELPBROWSER_REGISTRAR = "com.mathworks.mde.help.HelpBrowserRegistrar";
    static String MLCSHELPVIEWER_REGISTRAR = "com.mathworks.mde.help.CSHelpViewerRegistrar";
    static String MLWORKSPACE_REGISTRAR = "com.mathworks.mde.workspace.WorkspaceRegistrar";
    static String MLARRAYEDITOR_REGISTRAR = "com.mathworks.mde.array.ArrayEditorRegistrar";
    static String MLPATHBROWSER_REGISTRAR = "com.mathworks.pathtool.PathBrowserRegistrar";
    static String MATLABDESKTOP_REGISTRAR = "com.mathworks.mde.desk.MLDesktopRegistrar";
    static String MLCOMMANDHISTORY_REGISTRAR = "com.mathworks.mde.cmdhist.CmdHistoryRegistrar";
    static String MLCOMMANDWINDOW_REGISTRAR = "com.mathworks.mde.cmdwin.CommandWindowRegistrar";
    static String MLNEWINSPECTOR_REGISTRAR = "com.mathworks.mde.inspector.InspectorRegistrar";
    static String FILEEXCHANGE_REGISTRAR = "com.mathworks.webintegration.fileexchange.MatlabFileExchangeRegistrar";
    static String MLEXAMPLEGALLERY_REGISTRAR = "com.mathworks.mde.examples.ExampleGalleryRegistrar";
    private static Listener sListener;

}
