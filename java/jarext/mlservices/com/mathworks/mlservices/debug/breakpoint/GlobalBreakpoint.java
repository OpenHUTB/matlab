// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   GlobalBreakpoint.java

package com.mathworks.mlservices.debug.breakpoint;

import com.mathworks.jmi.CompletionObserver;
import com.mathworks.mlservices.MatlabDebugServices;
import java.util.Arrays;

// Referenced classes of package com.mathworks.mlservices.debug.breakpoint:
//            BreakpointBase

public class GlobalBreakpoint extends BreakpointBase
{
    public static final class Condition extends Enum
    {

        public static Condition[] values()
        {
            return (Condition[])$VALUES.clone();
        }

        public static Condition valueOf(String s)
        {
            return (Condition)Enum.valueOf(com/mathworks/mlservices/debug/breakpoint/GlobalBreakpoint$Condition, s);
        }

        public static final Condition ERROR;
        public static final Condition WARNING;
        public static final Condition CAUGHT_ERROR;
        public static final Condition ALL_ERROR;
        public static final Condition NAN_INF;
        private static final Condition $VALUES[];

        static 
        {
            ERROR = new Condition("ERROR", 0);
            WARNING = new Condition("WARNING", 1);
            CAUGHT_ERROR = new Condition("CAUGHT_ERROR", 2);
            ALL_ERROR = new Condition("ALL_ERROR", 3);
            NAN_INF = new Condition("NAN_INF", 4);
            $VALUES = (new Condition[] {
                ERROR, WARNING, CAUGHT_ERROR, ALL_ERROR, NAN_INF
            });
        }

        private Condition(String s, int i)
        {
            super(s, i);
        }
    }


    private GlobalBreakpoint(Condition condition, String as[])
    {
        fCondition = condition;
        fIds = null;
        if(as != null && as.length > 0)
            fIds = (String[])Arrays.copyOf(as, as.length);
    }

    public static GlobalBreakpoint createIfError(String as[])
    {
        return new GlobalBreakpoint(Condition.ERROR, as);
    }

    public static GlobalBreakpoint createIfError()
    {
        return createIfError(null);
    }

    public static GlobalBreakpoint createIfWarning(String as[])
    {
        return new GlobalBreakpoint(Condition.WARNING, as);
    }

    public static GlobalBreakpoint createIfWarning()
    {
        return createIfWarning(null);
    }

    public static GlobalBreakpoint createIfCaughtError(String as[])
    {
        return new GlobalBreakpoint(Condition.CAUGHT_ERROR, as);
    }

    public static GlobalBreakpoint createIfCaughtError()
    {
        return createIfCaughtError(null);
    }

    public static GlobalBreakpoint createIfAllError()
    {
        return new GlobalBreakpoint(Condition.ALL_ERROR, null);
    }

    public static GlobalBreakpoint createIfNanInf()
    {
        return new GlobalBreakpoint(Condition.NAN_INF, null);
    }

    public void set(CompletionObserver completionobserver)
    {
        MatlabDebugServices.debugCommandOnTheFly(toString(true), null, false, completionobserver);
    }

    public void clear(CompletionObserver completionobserver)
    {
        MatlabDebugServices.debugCommandOnTheFly(toString(false), null, false, completionobserver);
    }

    protected String toString(boolean flag)
    {
        StringBuilder stringbuilder = new StringBuilder(300);
        String s = "dbstop";
        if(!flag)
            s = "dbclear";
        if(flag)
            if(fCondition == Condition.ERROR)
                stringbuilder.append("dbclear if error;");
            else
            if(fCondition == Condition.WARNING)
                stringbuilder.append("dbclear if warning;");
            else
            if(fCondition == Condition.CAUGHT_ERROR)
                stringbuilder.append("dbclear if caught error;");
        if(fIds != null)
        {
            String as[] = fIds;
            int i = as.length;
            for(int j = 0; j < i; j++)
            {
                String s1 = as[j];
                stringbuilder.append(s);
                stringbuilder.append(" ");
                stringbuilder.append(getConditionString());
                stringbuilder.append(" ");
                stringbuilder.append(s1);
                stringbuilder.append(";");
            }

        } else
        {
            stringbuilder.append(s);
            stringbuilder.append(" ");
            stringbuilder.append(getConditionString());
            stringbuilder.append(";");
        }
        return stringbuilder.toString();
    }

    private String getConditionString()
    {
        String s = "";
        static class _cls1
        {

            static final int $SwitchMap$com$mathworks$mlservices$debug$breakpoint$GlobalBreakpoint$Condition[];

            static 
            {
                $SwitchMap$com$mathworks$mlservices$debug$breakpoint$GlobalBreakpoint$Condition = new int[Condition.values().length];
                try
                {
                    $SwitchMap$com$mathworks$mlservices$debug$breakpoint$GlobalBreakpoint$Condition[Condition.ERROR.ordinal()] = 1;
                }
                catch(NoSuchFieldError nosuchfielderror) { }
                try
                {
                    $SwitchMap$com$mathworks$mlservices$debug$breakpoint$GlobalBreakpoint$Condition[Condition.WARNING.ordinal()] = 2;
                }
                catch(NoSuchFieldError nosuchfielderror1) { }
                try
                {
                    $SwitchMap$com$mathworks$mlservices$debug$breakpoint$GlobalBreakpoint$Condition[Condition.CAUGHT_ERROR.ordinal()] = 3;
                }
                catch(NoSuchFieldError nosuchfielderror2) { }
                try
                {
                    $SwitchMap$com$mathworks$mlservices$debug$breakpoint$GlobalBreakpoint$Condition[Condition.ALL_ERROR.ordinal()] = 4;
                }
                catch(NoSuchFieldError nosuchfielderror3) { }
                try
                {
                    $SwitchMap$com$mathworks$mlservices$debug$breakpoint$GlobalBreakpoint$Condition[Condition.NAN_INF.ordinal()] = 5;
                }
                catch(NoSuchFieldError nosuchfielderror4) { }
            }
        }

        switch(_cls1..SwitchMap.com.mathworks.mlservices.debug.breakpoint.GlobalBreakpoint.Condition[fCondition.ordinal()])
        {
        case 1: // '\001'
            s = "if error";
            break;

        case 2: // '\002'
            s = "if warning";
            break;

        case 3: // '\003'
            s = "if caught error";
            break;

        case 4: // '\004'
            s = "if all error";
            break;

        case 5: // '\005'
            s = "if naninf";
            break;
        }
        return s;
    }

    private static final String IF_ERROR = "if error";
    private static final String IF_WARNING = "if warning";
    private static final String IF_CAUGHT_ERROR = "if caught error";
    private static final String IF_ALL_ERROR = "if all error";
    private static final String IF_NANINF = "if naninf";
    private final Condition fCondition;
    private String fIds[];
}
