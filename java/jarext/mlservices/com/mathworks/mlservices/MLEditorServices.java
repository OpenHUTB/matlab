// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   MLEditorServices.java

package com.mathworks.mlservices;

import com.mathworks.matlab.api.editor.Editor;
import com.mathworks.matlab.api.editor.EditorApplication;
import com.mathworks.services.mlx.MlxFileUtils;
import com.mathworks.util.Log;
import java.io.File;
import java.lang.reflect.Method;
import java.nio.file.Path;

// Referenced classes of package com.mathworks.mlservices:
//            MLServices

public final class MLEditorServices extends MLServices
{

    public MLEditorServices()
    {
    }

    public static synchronized EditorApplication getEditorApplication()
    {
        if(sMatlabEditorApplication == null)
            sMatlabEditorApplication = bootstrapMatlabEditorApplication();
        return sMatlabEditorApplication;
    }

    private static EditorApplication bootstrapMatlabEditorApplication()
    {
        EditorApplication editorapplication = null;
        try
        {
            Class class1 = Class.forName("com.mathworks.mde.editor.MatlabEditorApplication");
            Method method = class1.getMethod("getInstance", new Class[0]);
            editorapplication = (EditorApplication)method.invoke(class1, new Object[0]);
        }
        catch(Exception exception)
        {
            Log.logException(exception);
        }
        return editorapplication;
    }

    public static void openAndGoToLine(Path path, int i, boolean flag)
    {
        Editor editor = null;
        if(MlxFileUtils.isFileSupportedInLiveEditor(path.toString()))
            try
            {
                Class class1 = Class.forName("com.mathworks.mde.liveeditor.LiveEditorApplication");
                Method method = class1.getMethod("getInstance", new Class[0]);
                Object obj = method.invoke(null, new Object[0]);
                Method method1 = obj.getClass().getMethod("openLiveEditorClient", new Class[] {
                    java/io/File
                });
                editor = (Editor)method1.invoke(obj, new Object[] {
                    path.toFile()
                });
            }
            catch(Exception exception)
            {
                Log.logException(exception);
            }
        else
            editor = getEditorApplication().openEditor(path.toFile());
        if(editor != null)
        {
            editor.bringToFront();
            editor.goToLine(i, flag);
        }
    }

    private static EditorApplication sMatlabEditorApplication;
    public static final String UNTITLED_BUFFER_NAME_CLIENT_PROPERTY = "untitledBufferName";
}
