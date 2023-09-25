// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   MLInspectorServices.java

package com.mathworks.mlservices;

import com.mathworks.jmi.bean.UDDObject;
import com.mathworks.services.ObjectRegistry;
import javax.swing.SwingUtilities;

// Referenced classes of package com.mathworks.mlservices:
//            MLServices, MLInspectorRegistrar, MLInspector, MLServicesRegistry

public final class MLInspectorServices extends MLServices
{

    public MLInspectorServices()
    {
    }

    private static void setInspectorForUnitTesting(MLInspector mlinspector)
    {
        sInspector = mlinspector;
    }

    private static MLInspector createNewInstance()
    {
        sInspector = (MLInspector)getRegisteredService(MLServicesRegistry.MLNEWINSPECTOR_REGISTRAR, "getInspector");
        return sInspector;
    }

    private static MLInspector getInstance()
    {
        if(sInspector == null)
            sInspector = createNewInstance();
        return sInspector;
    }

    public static boolean isUDDObjectArrayInJava(Object aobj[])
    {
        boolean flag = true;
        int i = 0;
        do
        {
            if(i >= aobj.length)
                break;
            if(!(aobj[i] instanceof UDDObject))
            {
                flag = false;
                break;
            }
            i++;
        } while(true);
        return flag;
    }

    public static boolean isUDDObjectInJava(Object obj)
    {
        return obj instanceof UDDObject;
    }

    public static void invoke()
    {
        getInstance().invoke();
    }

    public static void inspectObject(Object obj)
    {
        getInstance().inspectObject(obj);
    }

    public static void inspectObjectArray(Object aobj[])
    {
        getInstance().inspectObjectArray(aobj);
    }

    public static void inspectObject(Object obj, boolean flag)
    {
        getInstance().inspectObject(obj, flag);
    }

    public static void inspectObjectArray(Object aobj[], boolean flag)
    {
        getInstance().inspectObjectArray(aobj, flag);
    }

    public static ObjectRegistry getRegistry()
    {
        return getInstance().getRegistry();
    }

    public static void selectProperty(String s)
    {
        if(s == null)
            return;
        MLInspector mlinspector = getInstance();
        if(!$assertionsDisabled && mlinspector == null)
            throw new AssertionError();
        if(SwingUtilities.isEventDispatchThread())
            mlinspector.selectProperty(s);
        else
            SwingUtilities.invokeLater(new Runnable(mlinspector, s) {

                public void run()
                {
                    instance.selectProperty(propertyName);
                }

                final MLInspector val$instance;
                final String val$propertyName;

            
            {
                instance = mlinspector;
                propertyName = s;
                super();
            }
            }
);
    }

    public static void refreshIfOpen()
    {
        getInstance().refreshIfOpen();
    }

    public static void inspectIfOpen(Object obj)
    {
        getInstance().inspectIfOpen(obj);
    }

    public static void activateInspector()
    {
        getInstance().activateInspector();
    }

    public static boolean isInspectorOpen()
    {
        return getInstance().isInspectorOpen();
    }

    public static void closeWindow()
    {
        getInstance().closeWindow();
    }

    public static void setShowReadOnly(boolean flag)
    {
        getInstance().setShowReadOnly(flag);
    }

    public static String getMixedValueDisplay()
    {
        return getInstance().getMixedValueDisplay();
    }

    public static void toFront()
    {
        getInstance().toFront();
    }

    public static void setAutoUpdate(boolean flag)
    {
        if(sInspector != null && sInspector.isInspectorOpen())
            sInspector.setAutoUpdate(flag);
    }

    public static boolean isAutoUpdate()
    {
        if(sInspector != null && sInspector.isInspectorOpen())
            return sInspector.isAutoUpdate();
        else
            return true;
    }

    private static MLInspector sInspector;
    static final boolean $assertionsDisabled = !com/mathworks/mlservices/MLInspectorServices.desiredAssertionStatus();

}
