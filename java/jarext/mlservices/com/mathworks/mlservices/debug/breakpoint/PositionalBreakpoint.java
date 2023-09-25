// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   PositionalBreakpoint.java

package com.mathworks.mlservices.debug.breakpoint;

import com.mathworks.jmi.CompletionObserver;
import com.mathworks.matlab.api.debug.Breakpoint;
import com.mathworks.mlservices.MatlabDebugServices;
import java.io.File;

// Referenced classes of package com.mathworks.mlservices.debug.breakpoint:
//            BreakpointBase

public class PositionalBreakpoint extends BreakpointBase
    implements Breakpoint
{

    public PositionalBreakpoint(int i, File file)
    {
        if(!$assertionsDisabled && i < 0)
            throw new AssertionError("The line number cannot be negative.");
        if(!$assertionsDisabled && file == null)
        {
            throw new AssertionError("The file cannot be null.");
        } else
        {
            fZeroBasedLineNumber = i;
            fFile = file;
            return;
        }
    }

    public void set(CompletionObserver completionobserver)
    {
        Object aobj[] = {
            getFile().getPath(), this
        };
        MatlabDebugServices.debugCommandOnTheFly(toString(true), aobj, true, completionobserver);
    }

    public void clear(CompletionObserver completionobserver)
    {
        Object aobj[] = {
            getFile().getPath(), this
        };
        MatlabDebugServices.debugCommandOnTheFly(toString(false), aobj, false, completionobserver);
    }

    public File getFile()
    {
        return fFile;
    }

    public int getZeroBasedLineNumber()
    {
        return fZeroBasedLineNumber;
    }

    public int getOneBasedLineNumber()
    {
        return fZeroBasedLineNumber + 1;
    }

    public boolean isEnabled()
    {
        return true;
    }

    public PositionalBreakpoint deriveBreakpoint(int i)
    {
        return new PositionalBreakpoint(i, fFile);
    }

    public PositionalBreakpoint deriveBreakpoint(File file)
    {
        return new PositionalBreakpoint(fZeroBasedLineNumber, file);
    }

    protected String toString(boolean flag)
    {
        if(flag)
            return sSetFunction;
        else
            return sClearFunction;
    }

    public static void clearAllBreakpoints(String s)
    {
        if(s == null || s.isEmpty())
        {
            return;
        } else
        {
            String s1 = (new StringBuilder()).append("dbclear all in '").append(s).append("'").toString();
            MatlabDebugServices.debugCommandOnTheFly(s1, null, false, null);
            return;
        }
    }

    public volatile Breakpoint deriveBreakpoint(int i)
    {
        return deriveBreakpoint(i);
    }

    private static String sSetFunction = "internal.matlab.desktop.editor.setBreakpoint";
    private static String sClearFunction = "internal.matlab.desktop.editor.clearBreakpoint";
    protected final int fZeroBasedLineNumber;
    protected final File fFile;
    static final boolean $assertionsDisabled = !com/mathworks/mlservices/debug/breakpoint/PositionalBreakpoint.desiredAssertionStatus();

}
