// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   GlobalBreakpointDBStatusHandler.java

package com.mathworks.mlservices.debug.breakpoint;

import com.mathworks.jmi.CompletionObserver;
import com.mathworks.mlservices.MatlabDebugObserver;

// Referenced classes of package com.mathworks.mlservices.debug.breakpoint:
//            GlobalBreakpointState

public class GlobalBreakpointDBStatusHandler
    implements CompletionObserver
{

    public GlobalBreakpointDBStatusHandler(MatlabDebugObserver matlabdebugobserver)
    {
        fStopIfError = false;
        fStopIfCaughtError = false;
        fStopIfWarning = false;
        fStopIfInfNan = false;
        fErrorIds = null;
        fCaughtErrorIds = null;
        fWarningIds = null;
        fObserver = matlabdebugobserver;
    }

    public void completed(int i, Object obj)
    {
        String s;
        int j;
        s = ((String)obj).trim();
        if(isErrorReply(s))
            return;
        j = s.length();
        if(j <= 0) goto _L2; else goto _L1
_L1:
        int k = 0;
_L4:
        if(k < j)
        {
            int i1 = s.substring(k).indexOf(';');
            if(!$assertionsDisabled && i1 == -1)
                throw new AssertionError((new StringBuilder()).append("Improperly formatted response from mdbstatus: ").append(s).toString());
            String s1 = s.substring(k, k + i1);
            k = k + i1 + 1;
            String s2 = s1;
            byte byte0 = -1;
            switch(s2.hashCode())
            {
            case 96784904: 
                if(s2.equals("error"))
                    byte0 = 0;
                break;

            case 429983076: 
                if(s2.equals("caught error"))
                    byte0 = 1;
                break;

            case 1124446108: 
                if(s2.equals("warning"))
                    byte0 = 2;
                break;

            case -1052797722: 
                if(s2.equals("naninf"))
                    byte0 = 3;
                break;
            }
            switch(byte0)
            {
            case 0: // '\0'
                fStopIfError = true;
                fErrorIds = getIdentifiers(s, k);
                break;

            case 1: // '\001'
                fStopIfCaughtError = true;
                fCaughtErrorIds = getIdentifiers(s, k);
                break;

            case 2: // '\002'
                fStopIfWarning = true;
                fWarningIds = getIdentifiers(s, k);
                break;

            case 3: // '\003'
                fStopIfInfNan = true;
                break;
            }
            continue; /* Loop/switch isn't completed */
        }
_L2:
        GlobalBreakpointState.handleDBStatusReply(fStopIfError, fStopIfCaughtError, fStopIfWarning, fStopIfInfNan, fErrorIds, fCaughtErrorIds, fWarningIds);
        int l = GlobalBreakpointState.getBitwiseState();
        if(l != 0)
            fObserver.doStopConditions(GlobalBreakpointState.getBitwiseState());
        break; /* Loop/switch isn't completed */
        if(true) goto _L4; else goto _L3
_L3:
    }

    private static String[] getIdentifiers(String s, int i)
    {
        int j = s.substring(i).indexOf(';');
        String s1 = s.substring(i, i + j);
        if(!s1.equals("all"))
            return initIdentifiers(s1);
        else
            return null;
    }

    private static boolean isErrorReply(String s)
    {
        if(!$assertionsDisabled && s == null)
        {
            throw new AssertionError("Response should not be null.");
        } else
        {
            int i = s.indexOf(';');
            boolean flag = i != -1;
            boolean flag1 = s.length() > 3 && s.indexOf("???") == 0;
            return !s.isEmpty() && (flag1 || !flag);
        }
    }

    private static String[] initIdentifiers(String s)
    {
        int i = s.length();
        int j = 0;
        int i1;
        for(i1 = 0; j < i; i1++)
        {
            int k = s.substring(j).indexOf(',');
            if(!$assertionsDisabled && k == -1)
                throw new AssertionError((new StringBuilder()).append("Improperly formatted response from mdbstatus: ").append(s).toString());
            j += k + 1;
        }

        String as[] = new String[i1];
        j = 0;
        for(int j1 = 0; j < i; j1++)
        {
            int l = s.substring(j).indexOf(',');
            if(!$assertionsDisabled && l == -1)
                throw new AssertionError((new StringBuilder()).append("Improperly formatted response from mdbstatus: ").append(s).toString());
            as[j1] = s.substring(j, j + l);
            j += l + 1;
        }

        return as;
    }

    private static final String ERROR_STRING = "error";
    private static final String CAUGHT_ERROR_STRING = "caught error";
    private static final String WARNING_STRING = "warning";
    private static final String INF_NAN_STRING = "naninf";
    private static final char SEMICOLON = 59;
    private static final char COMMA = 44;
    private final MatlabDebugObserver fObserver;
    private boolean fStopIfError;
    private boolean fStopIfCaughtError;
    private boolean fStopIfWarning;
    private boolean fStopIfInfNan;
    private String fErrorIds[];
    private String fCaughtErrorIds[];
    private String fWarningIds[];
    static final boolean $assertionsDisabled = !com/mathworks/mlservices/debug/breakpoint/GlobalBreakpointDBStatusHandler.desiredAssertionStatus();

}
