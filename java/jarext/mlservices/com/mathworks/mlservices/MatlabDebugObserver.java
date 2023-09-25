// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   MatlabDebugObserver.java

package com.mathworks.mlservices;

import com.mathworks.jmi.Matlab;
import java.util.EventListener;
import java.util.List;

// Referenced classes of package com.mathworks.mlservices:
//            MatlabDebugServices

public interface MatlabDebugObserver
    extends EventListener
{

    public abstract void doDBStop(String s, int i);

    public abstract void doDBClearAll();

    public abstract void doDBCont();

    public abstract void doDBQuit();

    public abstract void doSetBreakpoints(String s, List list);

    public abstract void doRemoveBreakpoints(String s, int ai[]);

    public abstract void doStopConditions(int i);

    public abstract void doDebugMode(boolean flag);

    public abstract void doWorkspaceChange(MatlabDebugServices.StackInfo stackinfo);

    public abstract void doDbupDbdownChange(String s, int i);

    public static final int DBSTOPIF_ERROR = 1;
    public static final int DBSTOPIF_WARNING = 2;
    public static final int DBSTOPIF_NANINF = 8;
    public static final int DBSTOPIF_ALLERROR = 16;
}
