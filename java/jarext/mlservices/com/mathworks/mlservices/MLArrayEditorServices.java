// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   MLArrayEditorServices.java

package com.mathworks.mlservices;

import com.mathworks.jmi.Matlab;
import com.mathworks.util.Log;

// Referenced classes of package com.mathworks.mlservices:
//            MLServices, MLArrayEditorRegistrar, MLArrayEditor, WorkspaceVariableAdaptor, 
//            MLServicesRegistry, WorkspaceVariable

public final class MLArrayEditorServices extends MLServices
{

    public MLArrayEditorServices()
    {
    }

    private static void init()
    {
        String s = MLServicesRegistry.MLARRAYEDITOR_REGISTRAR;
        synchronized(LOCK)
        {
            if(sArrayEditor == null)
            {
                String s1 = "getArrayEditor";
                sArrayEditor = (MLArrayEditor)getRegisteredService(s, s1);
            }
        }
    }

    private static MLArrayEditor getArrayEditor()
    {
        MLArrayEditor mlarrayeditor;
        synchronized(LOCK)
        {
            mlarrayeditor = sArrayEditor;
        }
        return mlarrayeditor;
    }

    /**
     * @deprecated Method openVariable is deprecated
     */

    public static void openVariable(String s)
    {
        openVariable(((WorkspaceVariable) (new WorkspaceVariableAdaptor(s))));
    }

    public static void openVariable(WorkspaceVariable workspacevariable)
    {
        init();
        getArrayEditor().openVariable(workspacevariable);
    }

    public static void openVariableLater(WorkspaceVariable workspacevariable)
    {
        init();
        Matlab.whenMatlabIdle(new Runnable(workspacevariable) {

            public void run()
            {
                try
                {
                    MLArrayEditorServices.openVariable(workspaceVariable);
                }
                catch(Exception exception)
                {
                    Log.log(exception.toString());
                }
            }

            final WorkspaceVariable val$workspaceVariable;

            
            {
                workspaceVariable = workspacevariable;
                super();
            }
        }
);
        getArrayEditor().openVariable(workspacevariable);
    }

    /**
     * @deprecated Method setEditable is deprecated
     */

    public static void setEditable(String s, boolean flag)
    {
        setEditable(((WorkspaceVariable) (new WorkspaceVariableAdaptor(s))), flag);
    }

    public static void setEditable(WorkspaceVariable workspacevariable, boolean flag)
    {
        init();
        getArrayEditor().setEditable(workspacevariable, flag);
    }

    /**
     * @deprecated Method isEditable is deprecated
     */

    public static boolean isEditable(String s)
    {
        return isEditable(((WorkspaceVariable) (new WorkspaceVariableAdaptor(s))));
    }

    public static boolean isEditable(WorkspaceVariable workspacevariable)
    {
        init();
        return getArrayEditor().isEditable(workspacevariable);
    }

    private static MLArrayEditor sArrayEditor = null;
    private static final Object LOCK = new Object();

}
