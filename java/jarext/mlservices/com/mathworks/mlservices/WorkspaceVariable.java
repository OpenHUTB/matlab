// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   WorkspaceVariable.java

package com.mathworks.mlservices;

import java.util.Arrays;

public class WorkspaceVariable
{

    public static boolean fnd(boolean flag)
    {
        boolean flag1 = sForceNonDefault;
        sForceNonDefault = flag;
        return flag1;
    }

    public String getVariableName()
    {
        return fVariableName;
    }

    public void setVariableName(String s)
    {
        fVariableName = s;
    }

    public String getVariableBaseName()
    {
        return fVariableBaseName;
    }

    private String extractVariableBaseName()
    {
        int ai[] = {
            0, 0, 0
        };
        String s = fVariableName;
        if(fVariableName != null && fVariableName.trim().length() > 0 && Character.isLetter(fVariableName.charAt(0)))
        {
            ai[0] = fVariableName.contains("{") ? fVariableName.indexOf("{") : -1;
            ai[1] = fVariableName.contains(".") ? fVariableName.indexOf(".") : -1;
            ai[2] = fVariableName.contains("(") ? fVariableName.indexOf("(") : -1;
            Arrays.sort(ai);
            int i = 0;
            do
            {
                if(i >= ai.length)
                    break;
                if(ai[i] > 0)
                {
                    s = fVariableName.substring(0, ai[i]);
                    break;
                }
                i++;
            } while(true);
        }
        return s;
    }

    public boolean isDefaultWorkspace()
    {
        if(sForceNonDefault)
            return false;
        else
            return fWorkspaceID == 0;
    }

    public String getWorkspaceVariableNameTemp()
    {
        return fVariableName;
    }

    public WorkspaceVariable(String s, int i)
    {
        if(s == null || s.trim().length() == 0 || s.length() == 0)
            throw new IllegalArgumentException("non empty variable name expected");
        if(i < 0)
        {
            throw new IllegalArgumentException("non negative integer workspace Id expected");
        } else
        {
            fVariableName = s;
            fWorkspaceID = i;
            fVariableBaseName = extractVariableBaseName();
            return;
        }
    }

    public int hashCode()
    {
        return fVariableName.hashCode() + fWorkspaceID;
    }

    public boolean equals(Object obj)
    {
        if(obj == this)
            return true;
        if(obj == null || !(obj instanceof WorkspaceVariable))
        {
            return false;
        } else
        {
            WorkspaceVariable workspacevariable = (WorkspaceVariable)com/mathworks/mlservices/WorkspaceVariable.cast(obj);
            return fVariableName.equals(workspacevariable.getVariableName()) && fWorkspaceID == workspacevariable.getWorkspaceID();
        }
    }

    public String toString()
    {
        if(isDefaultWorkspace())
            return fVariableName;
        else
            return (new StringBuilder()).append(fVariableName).append(" in Workspace ").append(fWorkspaceID).toString();
    }

    public int getWorkspaceID()
    {
        return fWorkspaceID;
    }

    private String fVariableName;
    private int fWorkspaceID;
    public static final int DEFAULT_ID = 0;
    private String fVariableBaseName;
    private static boolean sForceNonDefault = false;

}
