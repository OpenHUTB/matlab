// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   BreakpointBase.java

package com.mathworks.mlservices.debug.breakpoint;

import com.mathworks.jmi.CompletionObserver;
import com.mathworks.mlservices.MatlabDebugServices;

public abstract class BreakpointBase
{

    public BreakpointBase()
    {
    }

    protected String toString(boolean flag)
    {
        return "";
    }

    public static void clearAllBreakpoints()
    {
        String s = "builtin('dbclear', 'all')";
        MatlabDebugServices.debugCommandOnTheFly(s, null, false, null);
    }

    public final void apply(boolean flag, CompletionObserver completionobserver)
    {
        if(flag)
            set(completionobserver);
        else
            clear(completionobserver);
    }

    public abstract void set(CompletionObserver completionobserver);

    public abstract void clear(CompletionObserver completionobserver);

    protected static final String sConstDBStop = "dbstop";
    protected static final String sConstDBClear = "dbclear";
}
