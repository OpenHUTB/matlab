// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   MLArrayEditor.java

package com.mathworks.mlservices;


// Referenced classes of package com.mathworks.mlservices:
//            WorkspaceVariable

public interface MLArrayEditor
{

    /**
     * @deprecated Method openVariable is deprecated
     */

    public abstract void openVariable(String s);

    public abstract void openVariable(WorkspaceVariable workspacevariable);

    /**
     * @deprecated Method setEditable is deprecated
     */

    public abstract void setEditable(String s, boolean flag);

    public abstract void setEditable(WorkspaceVariable workspacevariable, boolean flag);

    /**
     * @deprecated Method isEditable is deprecated
     */

    public abstract boolean isEditable(String s);

    public abstract boolean isEditable(WorkspaceVariable workspacevariable);
}
