// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   MLHelpServices.java

package com.mathworks.mlservices;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.PrintStream;
import java.lang.reflect.Method;
import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.Iterator;
import javax.swing.SwingUtilities;

// Referenced classes of package com.mathworks.mlservices:
//            MLServices, MLHelpRegistrar, MLCSHelpRegistrar, MLHelpBrowser, 
//            MLCSHelpViewer, MLServicesRegistry, MLExampleGallery

public final class MLHelpServices extends MLServices
{

    public MLHelpServices()
    {
    }

    public static void invoke()
    {
        instantiateHelpBrowser();
        sHelpBrowser.invoke();
    }

    public static void registerMLHelpBrowser(String s, String s1, String s2)
    {
        sHelpBrowser = null;
        sMLHelpBrowserRegistrar = s;
        sMLHelpBrowserRegistrarMethod = s1;
    }

    public static void registerMLCSHelpViewer(String s, String s1)
    {
        sCSHelpViewer = null;
        sMLCSHelpViewerRegistrar = s;
        sMLCSHelpViewerRegistrarMethod = s1;
    }

    public static void reset()
    {
        sHelpBrowser = null;
        sCSHelpViewer = null;
        sMLHelpBrowserRegistrar = MLServicesRegistry.MLHELPBROWSER_REGISTRAR;
        sMLHelpBrowserRegistrarMethod = "getHelpBrowser";
        sJsHelpBrowserRegistrar = JS_HELP_BROWSER_HANDLER;
        sMLCSHelpViewerRegistrar = MLServicesRegistry.MLCSHELPVIEWER_REGISTRAR;
        sMLCSHelpViewerRegistrarMethod = "getCSHelpViewer";
    }

    public static void setCurrentLocation(String s)
    {
        instantiateHelpBrowser();
        sHelpBrowser.setCurrentLocation(s);
    }

    /**
     * @deprecated Method displayDocPage is deprecated
     */

    public static void displayDocPage(String s)
    {
        try
        {
            Class class1 = Class.forName(sJsHelpBrowserRegistrar);
            if(class1 != null)
            {
                Object obj = class1.newInstance();
                Method method = class1.getMethod("setCurrentLocation", new Class[] {
                    java/lang/String
                });
                if(method != null)
                    method.invoke(obj, new Object[] {
                        s
                    });
            }
        }
        catch(Exception exception)
        {
            System.out.println((new StringBuilder()).append("Problem calling ").append(sJsHelpBrowserRegistrar).append(".setCurrentLocation(").append(s).append(") ").append(exception.getMessage()).toString());
        }
    }

    /**
     * @deprecated Method displayHtmlText is deprecated
     */

    public static void displayHtmlText(String s)
    {
        try
        {
            Class class1 = Class.forName(sJsHelpBrowserRegistrar);
            if(class1 != null)
            {
                Object obj = class1.newInstance();
                Method method = class1.getMethod("setHtmlText", new Class[] {
                    java/lang/String
                });
                if(method != null)
                    method.invoke(obj, new Object[] {
                        s
                    });
            }
        }
        catch(Exception exception)
        {
            System.out.println((new StringBuilder()).append("Problem calling ").append(sJsHelpBrowserRegistrar).append(".setHtmlText(").append(s).append(") ").append(exception.getMessage()).toString());
        }
    }

    public static void showHelpPage(String s, String s1)
    {
        instantiateHelpBrowser();
        sHelpBrowser.showHelpPage(s, s1);
    }

    public static void setCurrentLocationAndHighlightKeywords(String s, String as[])
    {
        instantiateHelpBrowser();
        sHelpBrowser.setCurrentLocationAndHighlightKeywords(s, as);
    }

    public static void showHelpPageAndHighlightKeywords(String s, String s1, String as[])
    {
        instantiateHelpBrowser();
        sHelpBrowser.showHelpPageAndHighlightKeywords(s, s1, as);
    }

    public static boolean showProductPage(String s)
    {
        instantiateHelpBrowser();
        return sHelpBrowser.showProductPage(s);
    }

    public static String getCurrentLocation()
    {
        instantiateHelpBrowser();
        return sHelpBrowser.getCurrentLocation();
    }

    public static void setHtmlText(String s)
    {
        instantiateHelpBrowser();
        sHelpBrowser.setHtmlText(s);
    }

    public static void setDemoText(String s)
    {
        instantiateHelpBrowser();
        sHelpBrowser.setDemoText(s);
    }

    public static void setHtmlTextAndHighlightKeywords(String s, String as[])
    {
        instantiateHelpBrowser();
        sHelpBrowser.setHtmlTextAndHighlightKeywords(s, as);
    }

    public static String getHtmlText()
    {
        instantiateHelpBrowser();
        return sHelpBrowser.getHtmlText();
    }

    public static void docSearch(String s)
    {
        instantiateHelpBrowser();
        sHelpBrowser.docSearch(s);
    }

    public static void showDemos()
    {
        instantiateHelpBrowser();
        sHelpBrowser.showDemos();
    }

    public static void showDemos(String s)
    {
        instantiateHelpBrowser();
        sHelpBrowser.showDemos(s);
    }

    public static void showDemos(String s, String s1)
    {
        instantiateHelpBrowser();
        sHelpBrowser.showDemos(s, s1);
    }

    public static void displayTopic(String s, String s1)
    {
        instantiateHelpBrowser();
        sHelpBrowser.displayTopic(s, s1);
    }

    public static void cshDisplayTopic(Object obj, String s, String s1)
    {
        instantiateCSHelpViewer();
        sCSHelpViewer.displayTopic(obj, s, s1);
    }

    public static void cshDisplayTopic(String s, String s1)
    {
        instantiateCSHelpViewer();
        sCSHelpViewer.displayTopic(s, s1);
    }

    public static void cshSetSize(int i, int j)
    {
        instantiateCSHelpViewer();
        sCSHelpViewer.setSize(i, j);
    }

    public static void cshSetLocation(int i, int j)
    {
        instantiateCSHelpViewer();
        sCSHelpViewer.setLocation(i, j);
    }

    public static String getCSHText()
    {
        instantiateCSHelpViewer();
        return sCSHelpViewer.getHtmlText();
    }

    public static String getCSHLocation()
    {
        instantiateCSHelpViewer();
        return sCSHelpViewer.getCSHLocation();
    }

    private static MLHelpBrowser instantiateHelpBrowser()
    {
        if(sHelpBrowser == null)
        {
            sHelpBrowser = (MLHelpBrowser)getRegisteredService(sMLHelpBrowserRegistrar, sMLHelpBrowserRegistrarMethod);
            if(sHelpBrowser == null)
                sHelpBrowser = getDefaultHelpBrowser();
        }
        return sHelpBrowser;
    }

    private static MLHelpBrowser getDefaultHelpBrowser()
    {
        return (MLHelpBrowser)getRegisteredService(MLServicesRegistry.MLHELPBROWSER_REGISTRAR, "getHelpBrowser");
    }

    private static MLCSHelpViewer instantiateCSHelpViewer()
    {
        if(sCSHelpViewer == null)
        {
            sCSHelpViewer = (MLCSHelpViewer)getRegisteredService(sMLCSHelpViewerRegistrar, sMLCSHelpViewerRegistrarMethod);
            if(sCSHelpViewer == null)
                sCSHelpViewer = getDefaultCSHelpViewer();
        }
        return sCSHelpViewer;
    }

    private static MLCSHelpViewer getDefaultCSHelpViewer()
    {
        return (MLCSHelpViewer)getRegisteredService(MLServicesRegistry.MLCSHELPVIEWER_REGISTRAR, "getCSHelpViewer");
    }

    public static String getMapfileName(String s, String s1)
    {
        String s2 = null;
        try
        {
            Class class1 = Class.forName("com.mathworks.mlwidgets.help.HelpUtils");
            if(class1 != null)
            {
                Class aclass[] = {
                    java/lang/String, java/lang/String
                };
                Object aobj[] = {
                    s, s1
                };
                Method method = class1.getMethod("getMapfileName", aclass);
                if(method != null)
                    s2 = (String)method.invoke(null, aobj);
            }
        }
        catch(Exception exception)
        {
            String s3 = getErrorMessageForGetLocalizedFilename(s, s1, exception.getMessage());
            System.out.println(s3);
        }
        return s2;
    }

    private static String getErrorMessageForGetLocalizedFilename(String s, String s1, String s2)
    {
        String s3 = "Problem finding map file using com.mathworks.mlwidgets.help.HelpUtils.getMapfileName({0}, {1}): {2}";
        return MessageFormat.format(s3, new Object[] {
            s, s1, s2
        });
    }

    public static String getLocalizedFilename(String s)
    {
        String s1 = null;
        try
        {
            Class class1 = Class.forName("com.mathworks.mlwidgets.help.HelpUtils");
            if(class1 != null)
            {
                Class aclass[] = {
                    java/lang/String
                };
                Object aobj[] = {
                    s
                };
                Method method = class1.getMethod("getLocalizedFilename", aclass);
                if(method != null)
                    s1 = (String)method.invoke(null, aobj);
            }
        }
        catch(Exception exception)
        {
            System.out.println((new StringBuilder()).append("Problem finding getLocalizedFilename in com.mathworks.mlwidgets.help.HelpUtils: ").append(exception.getMessage()).toString());
        }
        return s1;
    }

    public static String getDocRoot()
    {
        String s = null;
        try
        {
            Class class1 = Class.forName("com.mathworks.mlwidgets.help.HelpPrefs");
            if(class1 != null)
            {
                Method method = class1.getMethod("getDocRoot", new Class[0]);
                if(method != null)
                    s = (String)method.invoke(null, new Object[0]);
            }
        }
        catch(Exception exception)
        {
            System.out.println((new StringBuilder()).append("Problem finding getDocRoot in com.mathworks.mlwidgets.help.HelpPrefs: ").append(exception.getMessage()).toString());
        }
        return s;
    }

    public static boolean setDocRoot(String s)
    {
        Boolean boolean1 = Boolean.valueOf(true);
        try
        {
            Class class1 = Class.forName("com.mathworks.mlwidgets.help.HelpPrefs");
            if(class1 != null)
            {
                Class aclass[] = {
                    java/lang/String
                };
                Object aobj[] = {
                    s
                };
                Method method = class1.getMethod("setDocRoot", aclass);
                if(method != null)
                    boolean1 = (Boolean)method.invoke(null, aobj);
            }
        }
        catch(Exception exception)
        {
            System.out.println((new StringBuilder()).append("Problem finding setDocRoot in com.mathworks.mlwidgets.help.HelpPrefs: ").append(exception.getMessage()).toString());
        }
        return boolean1.booleanValue();
    }

    public static String getHelpEndPoint()
    {
        String s = null;
        try
        {
            Class class1 = Class.forName("com.mathworks.mlwidgets.help.HelpPrefs");
            if(class1 != null)
            {
                Method method = class1.getMethod("getHelpEndPoint", new Class[0]);
                if(method != null)
                    s = (String)method.invoke(null, new Object[0]);
            }
        }
        catch(Exception exception)
        {
            System.out.println((new StringBuilder()).append("Problem finding getHelpEndPoint in com.mathworks.mlwidgets.help.HelpPrefs: ").append(exception.getMessage()).toString());
        }
        return s;
    }

    public static boolean setHelpEndPoint(String s)
    {
        Boolean boolean1 = Boolean.valueOf(true);
        try
        {
            Class class1 = Class.forName("com.mathworks.mlwidgets.help.HelpPrefs");
            if(class1 != null)
            {
                Class aclass[] = {
                    java/lang/String
                };
                Object aobj[] = {
                    s
                };
                Method method = class1.getMethod("setHelpEndPoint", aclass);
                if(method != null)
                    boolean1 = (Boolean)method.invoke(null, aobj);
            }
        }
        catch(Exception exception)
        {
            System.out.println((new StringBuilder()).append("Problem finding setHelpEndPoint in com.mathworks.mlwidgets.help.HelpPrefs: ").append(exception.getMessage()).toString());
        }
        return boolean1.booleanValue();
    }

    /**
     * @deprecated Method getDocCenterDomain is deprecated
     */

    public static String getDocCenterDomain()
    {
        String s = null;
        try
        {
            Class class1 = Class.forName("com.mathworks.mlwidgets.help.HelpPrefs");
            if(class1 != null)
            {
                Method method = class1.getMethod("getDocCenterDomain", new Class[0]);
                if(method != null)
                    s = (String)method.invoke(null, new Object[0]);
            }
        }
        catch(Exception exception)
        {
            System.out.println((new StringBuilder()).append("Problem finding getDocCenterDomain in com.mathworks.mlwidgets.help.HelpPrefs: ").append(exception.getMessage()).toString());
        }
        return s;
    }

    /**
     * @deprecated Method setDocCenterDomain is deprecated
     */

    public static boolean setDocCenterDomain(String s)
    {
        Boolean boolean1 = Boolean.valueOf(true);
        try
        {
            Class class1 = Class.forName("com.mathworks.mlwidgets.help.HelpPrefs");
            if(class1 != null)
            {
                Class aclass[] = {
                    java/lang/String
                };
                Object aobj[] = {
                    s
                };
                Method method = class1.getMethod("setDocCenterDomain", aclass);
                if(method != null)
                    boolean1 = (Boolean)method.invoke(null, aobj);
            }
        }
        catch(Exception exception)
        {
            System.out.println((new StringBuilder()).append("Problem finding setDocCenterDomain in com.mathworks.mlwidgets.help.HelpPrefs: ").append(exception.getMessage()).toString());
        }
        return boolean1.booleanValue();
    }

    public static String getDocRelease()
    {
        String s = null;
        try
        {
            Class class1 = Class.forName("com.mathworks.mlwidgets.help.HelpPrefs");
            if(class1 != null)
            {
                Method method = class1.getMethod("getDocRelease", new Class[0]);
                if(method != null)
                    s = (String)method.invoke(null, new Object[0]);
            }
        }
        catch(Exception exception)
        {
            System.out.println((new StringBuilder()).append("Problem finding getDocRelease in com.mathworks.mlwidgets.help.HelpPrefs: ").append(exception.getMessage()).toString());
        }
        return s;
    }

    public static boolean setDocRelease(String s)
    {
        Boolean boolean1 = Boolean.valueOf(true);
        try
        {
            Class class1 = Class.forName("com.mathworks.mlwidgets.help.HelpPrefs");
            if(class1 != null)
            {
                Class aclass[] = {
                    java/lang/String
                };
                Object aobj[] = {
                    s
                };
                Method method = class1.getMethod("setDocRelease", aclass);
                if(method != null)
                    boolean1 = (Boolean)method.invoke(null, aobj);
            }
        }
        catch(Exception exception)
        {
            System.out.println((new StringBuilder()).append("Problem finding setDocRelease in com.mathworks.mlwidgets.help.HelpPrefs: ").append(exception.getMessage()).toString());
        }
        if(!boolean1.booleanValue())
            System.out.println("Warning: doc release does not appear to be valid.");
        return boolean1.booleanValue();
    }

    public static boolean isNavigatorShowing()
    {
        return sShowNavigator;
    }

    public static void hideNavigator()
    {
        if(sShowNavigator)
        {
            sShowNavigator = false;
            notifyNavigatorListeners("hideNavigator");
        }
    }

    public static void showNavigator()
    {
        if(!sShowNavigator)
        {
            sShowNavigator = true;
            notifyNavigatorListeners("showNavigator");
        }
    }

    public static void toggleNavigator()
    {
        if(sShowNavigator)
            hideNavigator();
        else
            showNavigator();
    }

    public static void addNavigatorListener(ActionListener actionlistener)
    {
        if(sNavigatorListeners == null)
            sNavigatorListeners = new ArrayList();
        sNavigatorListeners.add(actionlistener);
    }

    public static void removeNavigatorListener(ActionListener actionlistener)
    {
        if(sNavigatorListeners != null)
            sNavigatorListeners.remove(actionlistener);
    }

    private static void notifyNavigatorListeners(String s)
    {
        if(sNavigatorListeners != null && sNavigatorListeners.size() > 0)
        {
            ActionEvent actionevent = new ActionEvent(com/mathworks/mlservices/MLHelpServices, 0, s);
            if(SwingUtilities.isEventDispatchThread())
                doNotifyNavigatorListeners(actionevent);
            else
                SwingUtilities.invokeLater(new Runnable(actionevent) {

                    public void run()
                    {
                        MLHelpServices.doNotifyNavigatorListeners(event);
                    }

                    final ActionEvent val$event;

            
            {
                event = actionevent;
                super();
            }
                }
);
        }
    }

    private static void doNotifyNavigatorListeners(ActionEvent actionevent)
    {
        ActionListener actionlistener;
        for(Iterator iterator = sNavigatorListeners.iterator(); iterator.hasNext(); actionlistener.actionPerformed(actionevent))
            actionlistener = (ActionListener)iterator.next();

    }

    public static MLHelpBrowser getHelpBrowser()
    {
        return sHelpBrowser;
    }

    public static MLCSHelpViewer getCSHViewer()
    {
        return sCSHelpViewer;
    }

    public static void showExampleGallery()
    {
        showDemos();
    }

    public static void showExampleGallery(String s)
    {
        showDemos();
    }

    private static MLHelpBrowser sHelpBrowser;
    private static MLCSHelpViewer sCSHelpViewer;
    private static MLExampleGallery sExampleGallery;
    private static boolean sShowNavigator = true;
    private static java.util.List sNavigatorListeners = null;
    private static String sMLHelpBrowserRegistrar;
    private static String sMLHelpBrowserRegistrarMethod = "getHelpBrowser";
    private static String sMLCSHelpViewerRegistrar;
    private static String sMLCSHelpViewerRegistrarMethod = "getCSHelpViewer";
    private static String JS_HELP_BROWSER_HANDLER;
    private static String sJsHelpBrowserRegistrar;

    static 
    {
        sMLHelpBrowserRegistrar = MLServicesRegistry.MLHELPBROWSER_REGISTRAR;
        sMLCSHelpViewerRegistrar = MLServicesRegistry.MLCSHELPVIEWER_REGISTRAR;
        JS_HELP_BROWSER_HANDLER = "com.mathworks.mde.help.JsHelpBrowserHandler";
        sJsHelpBrowserRegistrar = JS_HELP_BROWSER_HANDLER;
    }

}
