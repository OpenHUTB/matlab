// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   GlobalBreakpointState.java

package com.mathworks.mlservices.debug.breakpoint;

import com.mathworks.jmi.Matlab;
import com.mathworks.mlservices.MatlabDebugObserver;
import java.util.*;

// Referenced classes of package com.mathworks.mlservices.debug.breakpoint:
//            GlobalBreakpointDBStatusHandler

public class GlobalBreakpointState
{

    private GlobalBreakpointState()
    {
    }

    public static boolean isInitialized()
    {
        return sIsInitialized;
    }

    public static void triggerRefresh(Matlab matlab, MatlabDebugObserver matlabdebugobserver)
    {
        matlab.eval("mdbstatus", new GlobalBreakpointDBStatusHandler(matlabdebugobserver), 512);
    }

    public static int getBitwiseState()
    {
        throwIfNotInitialized();
        int i = 0;
        if(sStopIfError)
            i |= 1;
        if(sStopIfCaughtError)
            i |= 4;
        if(sStopIfWarning)
            i |= 2;
        if(sStopIfInfNan)
            i |= 8;
        return i;
    }

    public static boolean getStopIfErrorState()
        throws IllegalStateException
    {
        return getStopIfState(sStopIfError);
    }

    public static String[] getStopIfErrorIdentifiers()
        throws IllegalStateException
    {
        return getStopIfIdentifiers(sErrorIds);
    }

    public static boolean getStopIfCaughtErrorState()
        throws IllegalStateException
    {
        return getStopIfState(sStopIfCaughtError);
    }

    public static String[] getStopIfCaughtErrorIdentifiers()
        throws IllegalStateException
    {
        return getStopIfIdentifiers(sCaughtErrorIds);
    }

    public static boolean getStopIfWarningState()
        throws IllegalStateException
    {
        return getStopIfState(sStopIfWarning);
    }

    public static String[] getStopIfWarningIdentifiers()
        throws IllegalStateException
    {
        return getStopIfIdentifiers(sWarningIds);
    }

    public static boolean getStopIfNanInfState()
        throws IllegalStateException
    {
        return getStopIfState(sStopIfInfNan);
    }

    private static boolean getStopIfState(boolean flag)
        throws IllegalStateException
    {
        throwIfNotInitialized();
        return flag;
    }

    private static String[] getStopIfIdentifiers(Set set)
        throws IllegalStateException
    {
        throwIfNotInitialized();
        if(set.isEmpty())
        {
            return null;
        } else
        {
            String as[] = new String[set.size()];
            as = (String[])set.toArray(as);
            return as;
        }
    }

    private static void throwIfNotInitialized()
        throws IllegalStateException
    {
        if(!isInitialized())
            throw new IllegalStateException("GlobalBreakpointState has not yet initialized.");
        else
            return;
    }

    public static void handleMVMAddEvent(int i, String s)
    {
        switch(i)
        {
        case 0: // '\0'
            sStopIfError = true;
            addIdentifier(sErrorIds, s);
            break;

        case 1: // '\001'
            sStopIfCaughtError = true;
            addIdentifier(sCaughtErrorIds, s);
            break;

        case 2: // '\002'
            sStopIfWarning = true;
            addIdentifier(sWarningIds, s);
            break;

        case 3: // '\003'
            sStopIfInfNan = true;
            break;
        }
    }

    public static void handleMVMRemoveEvent(int i, String s)
    {
        switch(i)
        {
        default:
            break;

        case 0: // '\0'
            removeIdentifier(sErrorIds, s);
            if(sErrorIds.isEmpty())
                sStopIfError = false;
            break;

        case 1: // '\001'
            removeIdentifier(sCaughtErrorIds, s);
            if(sCaughtErrorIds.isEmpty())
                sStopIfCaughtError = false;
            break;

        case 2: // '\002'
            removeIdentifier(sWarningIds, s);
            if(sWarningIds.isEmpty())
                sStopIfWarning = false;
            break;

        case 3: // '\003'
            sStopIfInfNan = false;
            break;
        }
    }

    private static void addIdentifier(Set set, String s)
    {
        if("all".equals(s))
            set.clear();
        else
            set.add(s);
    }

    private static void removeIdentifier(Set set, String s)
    {
        if("all".equals(s))
            set.clear();
        else
            set.remove(s);
    }

    /**
     * @deprecated Method handleInterest is deprecated
     */

    public static void handleInterest(String as[][], boolean flag)
    {
        sIsInitialized = true;
        sErrorIds.clear();
        sStopIfError = setIdentifiersAndGetStopIfValue(as, 1, sErrorIds);
        sWarningIds.clear();
        sStopIfWarning = setIdentifiersAndGetStopIfValue(as, 2, sWarningIds);
        sCaughtErrorIds.clear();
        sStopIfCaughtError = setIdentifiersAndGetStopIfValue(as, 4, sCaughtErrorIds);
        sStopIfInfNan = flag;
    }

    private static boolean setIdentifiersAndGetStopIfValue(String as[][], int i, Set set)
    {
        if(as[i] != null)
        {
            String as1[] = as[i];
            if(as1.length > 0)
            {
                if(as1[0].equals("all"))
                    set.clear();
                else
                    set.addAll(Arrays.asList(as1));
                return true;
            }
        }
        return false;
    }

    public static void handleDBStatusReply(boolean flag, boolean flag1, boolean flag2, boolean flag3, String as[], String as1[], String as2[])
    {
        sIsInitialized = true;
        sStopIfError = flag;
        sStopIfCaughtError = flag1;
        sStopIfWarning = flag2;
        sStopIfInfNan = flag3;
        sErrorIds.clear();
        if(as != null)
            sErrorIds.addAll(Arrays.asList(as));
        sCaughtErrorIds.clear();
        if(as1 != null)
            sCaughtErrorIds.addAll(Arrays.asList(as1));
        sWarningIds.clear();
        if(as2 != null)
            sWarningIds.addAll(Arrays.asList(as2));
    }

    private static final int MVM_ERROR_ID = 0;
    private static final int MVM_CAUGHT_ERROR_ID = 1;
    private static final int MVM_WARNING_ID = 2;
    private static final int MVM_INF_NAN_ID = 3;
    static final String ALL_IDENTIFIERS = "all";
    private static final String DBSTATUS = "mdbstatus";
    private static final String UNINITIALIZED_ERROR_MSG = "GlobalBreakpointState has not yet initialized.";
    private static boolean sStopIfError = false;
    private static boolean sStopIfCaughtError = false;
    private static boolean sStopIfWarning = false;
    private static boolean sStopIfInfNan = false;
    private static Set sErrorIds = new HashSet();
    private static Set sCaughtErrorIds = new HashSet();
    private static Set sWarningIds = new HashSet();
    private static boolean sIsInitialized = false;

}
