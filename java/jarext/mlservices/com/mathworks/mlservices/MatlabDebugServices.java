// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   MatlabDebugServices.java

package com.mathworks.mlservices;

import com.mathworks.jmi.*;
import com.mathworks.mlservices.debug.breakpoint.BreakpointBase;
import com.mathworks.mlservices.debug.breakpoint.GlobalBreakpoint;
import com.mathworks.mlservices.debug.breakpoint.GlobalBreakpointState;
import com.mathworks.mlservices.debug.breakpoint.PositionalBreakpoint;
import com.mathworks.mvm.MVM;
import com.mathworks.mvm.MvmFactory;
import com.mathworks.mvm.exec.*;
import com.mathworks.services.Prefs;
import com.mathworks.services.message.MWMessage;
import com.mathworks.util.StringUtils;
import com.mathworks.util.event.GlobalEventListener;
import com.mathworks.util.event.GlobalEventManager;
import com.mathworks.widgets.debug.DebuggerManager;
import java.io.File;
import java.util.*;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.logging.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import javax.swing.event.ChangeEvent;
import javax.swing.event.EventListenerList;

// Referenced classes of package com.mathworks.mlservices:
//            MatlabDebugObserver, MatlabPauseObserver, MLExecuteServices, MLExecutionEvent, 
//            MLExecutionListener

public class MatlabDebugServices
{
    public static interface DebugEventTranslator
    {

        public abstract MWMessage translate(MWMessage mwmessage);

        public abstract String translatePath(String s);

        public abstract String translateWorkspaceName(String s, String s1);
    }

    private static class BusyExecutionListener
        implements MLExecutionListener
    {

        public void stateChanged(ChangeEvent changeevent)
        {
            MLExecutionEvent mlexecutionevent = (MLExecutionEvent)changeevent;
            MLExecutionEvent.InterpretedStatus interpretedstatus = mlexecutionevent.getInterpretedStatus();
            if(interpretedstatus != MLExecutionEvent.InterpretedStatus.BUSY && interpretedstatus != MLExecutionEvent.InterpretedStatus.BUSY_AND_PROFILING)
                MatlabDebugServices.setPausing(false);
        }

        private BusyExecutionListener()
        {
        }

    }

    private static class CtrlCListener
        implements MatlabListener
    {

        public void matlabEvent(MatlabEvent matlabevent)
        {
            if(matlabevent.getEventType() == 2)
                MatlabDebugServices.setPausing(false);
        }

        private CtrlCListener()
        {
        }

    }

    public static class StackInfo
    {

        public String[] getWorkspaceNames()
        {
            return (String[])Arrays.copyOf(fWorkspaceNames, fWorkspaceNames.length);
        }

        public String[] getFullFilenames()
        {
            return (String[])Arrays.copyOf(fFullNames, fFullNames.length);
        }

        public int getCurrentEntryIndex()
        {
            return fCurrentIndex;
        }

        public int[] getLineNumbers()
        {
            return Arrays.copyOf(fLineNumbers, fLineNumbers.length);
        }

        private String fWorkspaceNames[];
        private String fFullNames[];
        private int fLineNumbers[];
        private int fCurrentIndex;

        public StackInfo(String as[], String as1[], int ai[], int i)
        {
            fCurrentIndex = -1;
            if(as == null || as1 == null || ai == null)
                throw new IllegalArgumentException((new StringBuilder()).append("Null variables passed in. ").append(as).append(" ").append(as1).append(" ").append(ai).toString());
            if(i >= as1.length)
                throw new IllegalArgumentException((new StringBuilder()).append("Variable currentIndex is not valid: ").append(i).toString());
            if(as.length != as1.length || as.length != ai.length)
                throw new IllegalArgumentException((new StringBuilder()).append("List sizes do not correspond.").append(as.length).append(" ").append(as1.length).append(" ").append(ai.length).toString());
            fFullNames = (String[])Arrays.copyOf(as, as.length);
            fWorkspaceNames = new String[as1.length + 1];
            System.arraycopy(as1, 0, fWorkspaceNames, 0, as1.length);
            fWorkspaceNames[as1.length] = "<Base>";
            fLineNumbers = Arrays.copyOf(ai, ai.length);
            if(i == -1)
                i = fWorkspaceNames.length - 1;
            fCurrentIndex = i;
        }
    }

    public static class BreakpointInfo
    {

        public int getLineNumber()
        {
            return fLineNumber;
        }

        public int getAnonIndex()
        {
            return fAnonIndex;
        }

        public String getCondition()
        {
            return fCondition;
        }

        private final String fCondition;
        private final int fLineNumber;
        private final int fAnonIndex;

        public BreakpointInfo(int i, String s, int j)
        {
            fCondition = s;
            fLineNumber = i;
            fAnonIndex = j;
        }
    }

    /**
     * @deprecated Class MatlabStopIf is deprecated
     */

    public static class MatlabStopIf
    {

        public void setStopIfError(int i, String as[])
        {
            fStopIfError = getState(i, as);
            if(i == 2 && as != null && as.length > 0)
                fErrorIDs = (String[])Arrays.copyOf(as, as.length);
        }

        public void setStopIfCaughtError(int i, String as[])
        {
            fStopIfCaughtError = getState(i, as);
            if(i == 2 && as != null && as.length > 0)
                fCaughtErrorIDs = (String[])Arrays.copyOf(as, as.length);
        }

        public void setStopIfWarning(int i, String as[])
        {
            fStopIfWarning = getState(i, as);
            if(i == 2 && as != null && as.length > 0)
                fWarningIDs = (String[])Arrays.copyOf(as, as.length);
        }

        private boolean getState(int i, String as[])
        {
            if(i == 0)
                return false;
            if(i == 1)
                return true;
            return i == 2 && as != null && as.length > 0;
        }

        public void setStopIfNanInf(int i)
        {
            fStopIfNanInf = i == 1;
        }

        public void sendToMATLAB()
        {
            GlobalBreakpoint.createIfError(fErrorIDs).apply(fStopIfError, null);
            GlobalBreakpoint.createIfCaughtError(fCaughtErrorIDs).apply(fStopIfCaughtError, null);
            GlobalBreakpoint.createIfWarning(fWarningIDs).apply(fStopIfWarning, null);
            GlobalBreakpoint.createIfNanInf().apply(fStopIfNanInf, null);
        }

        private boolean fStopIfError;
        private boolean fStopIfCaughtError;
        private boolean fStopIfWarning;
        private boolean fStopIfNanInf;
        private String fErrorIDs[];
        private String fCaughtErrorIDs[];
        private String fWarningIDs[];

        public MatlabStopIf()
        {
            fStopIfError = false;
            fStopIfCaughtError = false;
            fStopIfWarning = false;
            fStopIfNanInf = false;
            fErrorIDs = null;
            fCaughtErrorIDs = null;
            fWarningIDs = null;
            if(!MatlabDebugServices.isInitialized())
            {
                return;
            } else
            {
                fStopIfError = GlobalBreakpointState.getStopIfErrorState();
                fStopIfCaughtError = GlobalBreakpointState.getStopIfCaughtErrorState();
                fStopIfWarning = GlobalBreakpointState.getStopIfWarningState();
                fStopIfNanInf = GlobalBreakpointState.getStopIfNanInfState();
                fErrorIDs = GlobalBreakpointState.getStopIfErrorIdentifiers();
                fCaughtErrorIDs = GlobalBreakpointState.getStopIfCaughtErrorIdentifiers();
                fWarningIDs = GlobalBreakpointState.getStopIfWarningIdentifiers();
                return;
            }
        }
    }

    private static class DefaultMatlabPauseObserver
        implements MatlabPauseObserver
    {

        public void doPause()
        {
            Object aobj[] = sMatlabPauseObservers.getListenerList();
            for(int i = 0; i < aobj.length; i += 2)
                if(aobj[i] == com/mathworks/mlservices/MatlabPauseObserver)
                {
                    MatlabPauseObserver matlabpauseobserver = (MatlabPauseObserver)aobj[i + 1];
                    matlabpauseobserver.doPause();
                }

        }

        private static EventListenerList sMatlabPauseObservers = new EventListenerList();



        private DefaultMatlabPauseObserver()
        {
        }

    }

    private static class DefaultMatlabDebugObserver
        implements MatlabDebugObserver
    {

        public void doDBStop(String s, int i)
        {
            Object aobj[] = sMatlabDebugObservers.getListenerList();
            for(int j = 0; j < aobj.length; j += 2)
                if(aobj[j] == com/mathworks/mlservices/MatlabDebugObserver)
                {
                    MatlabDebugObserver matlabdebugobserver = (MatlabDebugObserver)aobj[j + 1];
                    matlabdebugobserver.doDBStop(s, i);
                }

        }

        public void doDBClearAll()
        {
            Object aobj[] = sMatlabDebugObservers.getListenerList();
            for(int i = 0; i < aobj.length; i += 2)
                if(aobj[i] == com/mathworks/mlservices/MatlabDebugObserver)
                {
                    MatlabDebugObserver matlabdebugobserver = (MatlabDebugObserver)aobj[i + 1];
                    matlabdebugobserver.doDBClearAll();
                }

        }

        public void doDBCont()
        {
            Object aobj[] = sMatlabDebugObservers.getListenerList();
            for(int i = 0; i < aobj.length; i += 2)
                if(aobj[i] == com/mathworks/mlservices/MatlabDebugObserver)
                {
                    MatlabDebugObserver matlabdebugobserver = (MatlabDebugObserver)aobj[i + 1];
                    matlabdebugobserver.doDBCont();
                }

        }

        public void doDBQuit()
        {
            Object aobj[] = sMatlabDebugObservers.getListenerList();
            for(int i = 0; i < aobj.length; i += 2)
                if(aobj[i] == com/mathworks/mlservices/MatlabDebugObserver)
                {
                    MatlabDebugObserver matlabdebugobserver = (MatlabDebugObserver)aobj[i + 1];
                    matlabdebugobserver.doDBQuit();
                }

        }

        public void doSetBreakpoints(String s, List list)
        {
            Object aobj[] = sMatlabDebugObservers.getListenerList();
            s = MLFileUtils.mapPFileToMFile(s);
            for(int i = 0; i < aobj.length; i += 2)
                if(aobj[i] == com/mathworks/mlservices/MatlabDebugObserver)
                {
                    MatlabDebugObserver matlabdebugobserver = (MatlabDebugObserver)aobj[i + 1];
                    matlabdebugobserver.doSetBreakpoints(s, list);
                }

        }

        public void doRemoveBreakpoints(String s, int ai[])
        {
            Object aobj[] = sMatlabDebugObservers.getListenerList();
            s = MLFileUtils.mapPFileToMFile(s);
            for(int i = 0; i < aobj.length; i += 2)
                if(aobj[i] == com/mathworks/mlservices/MatlabDebugObserver)
                {
                    MatlabDebugObserver matlabdebugobserver = (MatlabDebugObserver)aobj[i + 1];
                    matlabdebugobserver.doRemoveBreakpoints(s, ai);
                }

        }

        public void doStopConditions(int i)
        {
            Object aobj[] = sMatlabDebugObservers.getListenerList();
            for(int j = 0; j < aobj.length; j += 2)
                if(aobj[j] == com/mathworks/mlservices/MatlabDebugObserver)
                {
                    MatlabDebugObserver matlabdebugobserver = (MatlabDebugObserver)aobj[j + 1];
                    matlabdebugobserver.doStopConditions(i);
                }

        }

        public void doDebugMode(boolean flag)
        {
            Object aobj[] = sMatlabDebugObservers.getListenerList();
            for(int i = 0; i < aobj.length; i += 2)
                if(aobj[i] == com/mathworks/mlservices/MatlabDebugObserver)
                {
                    MatlabDebugObserver matlabdebugobserver = (MatlabDebugObserver)aobj[i + 1];
                    matlabdebugobserver.doDebugMode(flag);
                }

        }

        public void doWorkspaceChange(StackInfo stackinfo)
        {
            if(stackinfo != null)
            {
                MatlabDebugServices.sWS_SCOPEStackInfo = stackinfo;
                Object aobj[] = sMatlabDebugObservers.getListenerList();
                for(int i = 0; i < aobj.length; i += 2)
                    if(aobj[i] == com/mathworks/mlservices/MatlabDebugObserver)
                    {
                        MatlabDebugObserver matlabdebugobserver = (MatlabDebugObserver)aobj[i + 1];
                        matlabdebugobserver.doWorkspaceChange(MatlabDebugServices.sWS_SCOPEStackInfo);
                    }

            }
        }

        public void doDbupDbdownChange(String s, int i)
        {
            Object aobj[] = sMatlabDebugObservers.getListenerList();
            for(int j = 0; j < aobj.length; j += 2)
                if(aobj[j] == com/mathworks/mlservices/MatlabDebugObserver)
                {
                    MatlabDebugObserver matlabdebugobserver = (MatlabDebugObserver)aobj[j + 1];
                    matlabdebugobserver.doDbupDbdownChange(s, i);
                }

        }

        private static EventListenerList sMatlabDebugObservers = new EventListenerList();



        private DefaultMatlabDebugObserver()
        {
        }

    }

    static class DebugDispatch
        implements CompletionObserver
    {
        static class DebugExitStackCheck
            implements CompletionObserver
        {

            public void completed(int i, Object obj)
            {
                StackInfo stackinfo = MatlabDebugServices.createStackInfo(obj);
                if(stackinfo == null)
                {
                    MatlabDebugServices.setInDebugMode(false);
                } else
                {
                    boolean flag = stackinfo.getFullFilenames().length > 0;
                    String s = flag ? stackinfo.getFullFilenames()[0] : "";
                    int j = flag ? stackinfo.getLineNumbers()[0] : 0;
                    MatlabDebugServices.DEFAULT_MATLAB_DEBUG_OBSERVER.doDBStop(s, j);
                }
            }

            DebugExitStackCheck()
            {
            }
        }


        public void completed(int i, Object obj)
        {
            dispatchMessage(obj, MatlabDebugServices.DEFAULT_MATLAB_DEBUG_OBSERVER);
        }

        private void dispatchMessage(Object obj, MatlabDebugObserver matlabdebugobserver)
        {
            MWMessage mwmessage = (MWMessage)obj;
            if(MatlabDebugServices.sEventTranslator != null)
                mwmessage = MatlabDebugServices.sEventTranslator.translate(mwmessage);
            Integer integer = (Integer)mwmessage.get("eventid");
            if(integer == null)
                return;
            switch(integer.intValue())
            {
            case 134217728: 
                MatlabDebugServices.LOGGER.info("DEBUG_GO");
                interestDebugGo(matlabdebugobserver);
                break;

            case 268435456: 
                MatlabDebugServices.LOGGER.info("DEBUG_EXIT");
                interestDebugExit(matlabdebugobserver);
                break;

            case 67108864: 
                MatlabDebugServices.LOGGER.info("DEBUG_STOP");
                interestDebugStop(mwmessage, matlabdebugobserver);
                break;

            case 33554432: 
                interestDebugStopIf(mwmessage, matlabdebugobserver);
                break;

            case -2147483648: 
                interestDebugBPAdd(mwmessage, matlabdebugobserver);
                break;

            case 1073741824: 
                interestDebugBPClear(matlabdebugobserver);
                break;

            case 536870912: 
                interestDebugBPDelete(mwmessage, matlabdebugobserver);
                break;

            case 16777216: 
                interestDbupDbdown(mwmessage, matlabdebugobserver);
                break;
            }
        }

        private void interestDebugExit(MatlabDebugObserver matlabdebugobserver)
        {
            matlabdebugobserver.doDBQuit();
            MatlabDebugServices.executeDBstack(MatlabDebugServices.sMatlab, sDebugExitStackCheck);
        }

        private void interestDebugStop(MWMessage mwmessage, MatlabDebugObserver matlabdebugobserver)
        {
            if(mwmessage == null)
                return;
            String s = (String)mwmessage.get("string");
            Integer integer = (Integer)mwmessage.get("lineno");
            if(s == null || integer == null)
                return;
            MatlabDebugServices.setInDebugMode(true);
            MatlabDebugServices.setPausing(false);
            MatlabDebugServices.sInKeyboardMode = false;
            Integer integer1 = (Integer)mwmessage.get("prompt");
            if(integer1 != null)
                MatlabDebugServices.sInKeyboardMode = integer1.intValue() == Matlab.KEYBOARD_PROMPT;
            matlabdebugobserver.doDBStop(s, integer.intValue());
        }

        private void interestDebugGo(MatlabDebugObserver matlabdebugobserver)
        {
            matlabdebugobserver.doDBCont();
        }

        private void interestDebugStopIf(MWMessage mwmessage, MatlabDebugObserver matlabdebugobserver)
        {
            if(mwmessage == null)
            {
                return;
            } else
            {
                int i = ((Integer)mwmessage.get("value")).intValue();
                boolean flag = (i & 8) != 0;
                String as[][] = (String[][])(String[][])mwmessage.get("string");
                GlobalBreakpointState.handleInterest(as, flag);
                matlabdebugobserver.doStopConditions(i);
                return;
            }
        }

        private void interestDebugBPAdd(MWMessage mwmessage, MatlabDebugObserver matlabdebugobserver)
        {
            MWMessage amwmessage[] = (MWMessage[])(MWMessage[])mwmessage.get("result");
            if(amwmessage == null)
                return;
            int j = amwmessage.length;
            if(j <= 0)
                return;
            HashMap hashmap = new HashMap();
            for(int i = 0; i < j; i++)
            {
                String s = (String)amwmessage[i].get("string");
                if(s == null)
                    continue;
                Object obj = (List)hashmap.get(s);
                if(obj == null)
                {
                    obj = new ArrayList();
                    hashmap.put(s, obj);
                }
                Integer integer = (Integer)amwmessage[i].get("lineno");
                Integer integer1 = (Integer)amwmessage[i].get("anonymous");
                String s2 = (String)amwmessage[i].get("value");
                ((List) (obj)).add(new BreakpointInfo(integer.intValue() - 1, s2, integer1.intValue()));
            }

            String s1;
            for(Iterator iterator = hashmap.keySet().iterator(); iterator.hasNext(); matlabdebugobserver.doSetBreakpoints(s1, (List)hashmap.get(s1)))
                s1 = (String)iterator.next();

        }

        private void interestDebugBPDelete(MWMessage mwmessage, MatlabDebugObserver matlabdebugobserver)
        {
            MWMessage amwmessage[] = (MWMessage[])(MWMessage[])mwmessage.get("result");
            if(amwmessage == null)
                return;
            int i = amwmessage.length;
            if(i <= 0)
                return;
            String s = (String)amwmessage[0].get("string");
            if(s == null)
                return;
            int ai[] = new int[i];
            for(int j = 0; j < i; j++)
            {
                Integer integer = (Integer)amwmessage[j].get("lineno");
                ai[j] = integer.intValue() - 1;
            }

            matlabdebugobserver.doRemoveBreakpoints(s, ai);
        }

        private void interestDebugBPClear(MatlabDebugObserver matlabdebugobserver)
        {
            matlabdebugobserver.doDBClearAll();
        }

        private void interestDbupDbdown(MWMessage mwmessage, MatlabDebugObserver matlabdebugobserver)
        {
            String s = (String)mwmessage.get("string");
            if(s == null || s.isEmpty())
                s = "<Base>";
            int i = ((Integer)mwmessage.get("lineno")).intValue() - 1;
            matlabdebugobserver.doDbupDbdownChange(s, i);
        }

        private static final DebugExitStackCheck sDebugExitStackCheck = new DebugExitStackCheck();


        DebugDispatch()
        {
        }
    }

    static class StackDispatch
        implements CompletionObserver
    {
        private static abstract class HowMany extends Enum
        {

            public static HowMany[] values()
            {
                return (HowMany[])$VALUES.clone();
            }

            public static HowMany valueOf(String s)
            {
                return (HowMany)Enum.valueOf(com/mathworks/mlservices/MatlabDebugServices$StackDispatch$HowMany, s);
            }

            abstract HowMany increment();

            public HowMany clear()
            {
                return NONE;
            }

            public static final HowMany NONE;
            public static final HowMany ONE;
            public static final HowMany MORE;
            private static final HowMany $VALUES[];

            static 
            {
                NONE = new HowMany("NONE", 0) {

                    HowMany increment()
                    {
                        return ONE;
                    }

                }
;
                ONE = new HowMany("ONE", 1) {

                    HowMany increment()
                    {
                        return MORE;
                    }

                }
;
                MORE = new HowMany("MORE", 2) {

                    HowMany increment()
                    {
                        return MORE;
                    }

                }
;
                $VALUES = (new HowMany[] {
                    NONE, ONE, MORE
                });
            }

            private HowMany(String s, int i)
            {
                super(s, i);
            }

        }


        public boolean isWaiting()
        {
            return fState != HowMany.NONE;
        }

        private boolean moreThanOneRequest()
        {
            return fState == HowMany.MORE;
        }

        public void setWaiting(boolean flag)
        {
            if(flag)
                fState = fState.increment();
            else
                fState = fState.clear();
        }

        public void completed(int i, Object obj)
        {
            StackInfo stackinfo = MatlabDebugServices.createStackInfo(obj);
            if(stackinfo != null)
                MatlabDebugServices.DEFAULT_MATLAB_DEBUG_OBSERVER.doWorkspaceChange(stackinfo);
            if(moreThanOneRequest())
                MatlabDebugServices.executeDBstack(MatlabDebugServices.sMatlab, MatlabDebugServices.STACK_DISPATCH);
            setWaiting(false);
        }

        private volatile HowMany fState;

        StackDispatch()
        {
            fState = HowMany.NONE;
        }
    }

    static class StackCallback
        implements CompletionObserver
    {

        public void completed(int i, Object obj)
        {
            if(!MatlabDebugServices.isInitialized() || MatlabDebugServices.isDebugging())
            {
                MWMessage mwmessage = (MWMessage)obj;
                Integer integer = (Integer)mwmessage.get("eventid");
                if(integer == null)
                    return;
                if(integer.intValue() == 0x80000000)
                {
                    if(!MatlabDebugServices.STACK_DISPATCH.isWaiting())
                        MatlabDebugServices.executeDBstack(MatlabDebugServices.sMatlab, MatlabDebugServices.STACK_DISPATCH);
                    MatlabDebugServices.STACK_DISPATCH.setWaiting(true);
                }
            }
        }

        StackCallback()
        {
        }
    }

    static class DBStatusDBStackCallback
        implements CompletionObserver
    {

        public void completed(int i, Object obj)
        {
            if(fReplyType == 1)
                handleBreakpoints((String)obj);
            else
            if(fReplyType == 2)
                handleStackReply(i, obj);
        }

        private void handleBreakpoints(String s)
        {
            if(isErrorReply(s))
                return;
            if(fObserver == null || fFilename == null)
                return;
            int l = s.length();
            if(l > 0)
            {
                int j = 0;
                char ac[] = new char[256];
                ArrayList arraylist = new ArrayList();
                do
                {
                    if(j >= l)
                        break;
                    for(; j < l - 1 && !Character.isDigit(s.charAt(j)); j++);
                    if(j >= l - 1)
                        break;
                    int i = 0;
                    while(Character.isDigit(s.charAt(j))) 
                        ac[i++] = s.charAt(j++);
                    int k = Integer.valueOf(new String(ac, 0, i)).intValue();
                    arraylist.add(new BreakpointInfo(k - 1, "", -1));
                    fObserver.doSetBreakpoints(fFilename, arraylist);
                } while(true);
            }
        }

        private static void handleStackReply(int i, Object obj)
        {
            StackInfo stackinfo = MatlabDebugServices.createStackInfo(obj);
            if(!DebuggerManager.isDebugging())
                stackinfo = null;
            if(!MatlabDebugServices.sDebugModeSet)
            {
                boolean flag = stackinfo != null;
                MatlabDebugServices.sInDebugMode = !flag;
                MatlabDebugServices.setInDebugMode(flag);
            }
            MatlabDebugServices.DEFAULT_MATLAB_DEBUG_OBSERVER.doWorkspaceChange(stackinfo);
        }

        private static boolean isErrorReply(String s)
        {
            if(!$assertionsDisabled && s == null)
                throw new AssertionError("Response should not be null.");
            return s.length() > 3 && s.indexOf("???") == 0;
        }

        int fReplyType;
        String fFilename;
        MatlabDebugObserver fObserver;
        static final boolean $assertionsDisabled = !com/mathworks/mlservices/MatlabDebugServices.desiredAssertionStatus();


        public DBStatusDBStackCallback(int i, String s, MatlabDebugObserver matlabdebugobserver)
        {
            fReplyType = i;
            fFilename = s;
            fObserver = matlabdebugobserver;
        }

        public DBStatusDBStackCallback(int i)
        {
            fReplyType = i;
            fFilename = null;
            fObserver = null;
        }
    }


    public MatlabDebugServices()
    {
        fCompletionObserver = null;
    }

    public static void initialize()
    {
    }

    public static boolean isInitialized()
    {
        return GlobalBreakpointState.isInitialized() && sDebugModeSet;
    }

    public static void addDefaultObserverListener(MatlabDebugObserver matlabdebugobserver)
    {
        DefaultMatlabDebugObserver.sMatlabDebugObservers.add(com/mathworks/mlservices/MatlabDebugObserver, matlabdebugobserver);
        if(isInitialized())
        {
            matlabdebugobserver.doDebugMode(isDebugging());
            if(isDebugging() && sWS_SCOPEStackInfo != null)
                matlabdebugobserver.doWorkspaceChange(sWS_SCOPEStackInfo);
        }
    }

    public static void removeDefaultObserverListener(MatlabDebugObserver matlabdebugobserver)
    {
        DefaultMatlabDebugObserver.sMatlabDebugObservers.remove(com/mathworks/mlservices/MatlabDebugObserver, matlabdebugobserver);
    }

    public static void setMWDebugOverride(boolean flag)
    {
        sMWDebugOverride = flag;
    }

    public static boolean isMWDebugOverride()
    {
        return sMWDebugOverride;
    }

    public static void setEventTranslator(DebugEventTranslator debugeventtranslator)
    {
        sEventTranslator = debugeventtranslator;
    }

    public static void clearEventTranslator()
    {
        sEventTranslator = null;
    }

    public static void addDefaultPauseObserverListener(MatlabPauseObserver matlabpauseobserver)
    {
        DefaultMatlabPauseObserver.sMatlabPauseObservers.add(com/mathworks/mlservices/MatlabPauseObserver, matlabpauseobserver);
    }

    public static void removeDefaultPauseObserverListener(MatlabPauseObserver matlabpauseobserver)
    {
        DefaultMatlabPauseObserver.sMatlabPauseObservers.remove(com/mathworks/mlservices/MatlabPauseObserver, matlabpauseobserver);
    }

    /**
     * @deprecated Method executeDBstack is deprecated
     */

    public static void executeDBstack(Matlab matlab, CompletionObserver completionobserver)
    {
        if(matlab != null)
        {
            MVM mvm = MvmFactory.getCurrentMVM();
            executeDBStack(mvm, completionobserver);
        }
    }

    public static void executeDBStack(MVM mvm, CompletionObserver completionobserver)
    {
        MatlabFevalRequest matlabfevalrequest = new MatlabFevalRequest("dbstack", Integer.valueOf(2), sDBStackArgs);
        matlabfevalrequest.setDisableBreakpoints(true);
        submitRequest(mvm, matlabfevalrequest, completionobserver);
    }

    public static StackInfo createStackInfo(Object obj)
    {
        StackInfo stackinfo = null;
        if(!(obj instanceof Object[]))
            return stackinfo;
        if(sDebugModeSet && (!sInDebugMode || !DebuggerManager.isDebugging()))
            return null;
        Object aobj[] = (Object[])(Object[])obj;
        Object aobj1[] = (Object[])(Object[])((Object[])(Object[])aobj[0])[1];
        int i = aobj1.length;
        String as[] = new String[i];
        String as1[] = new String[i];
        int ai[] = new int[i];
        for(int j = 0; j != i; j++)
        {
            Object aobj2[] = (Object[])(Object[])aobj1[j];
            as[j] = (String)aobj2[0];
            as1[j] = (String)aobj2[1];
            if(as[j].length() == 0)
                as[j] = as1[j];
            if(sEventTranslator != null)
            {
                as1[j] = sEventTranslator.translateWorkspaceName(as[j], as1[j]);
                as[j] = sEventTranslator.translatePath(as[j]);
            }
            ai[j] = (int)Math.abs(((double[])(double[])aobj2[2])[0]);
        }

        int l = (int)((double[])(double[])aobj[1])[0];
        int k;
        if(l > i)
            k = -1;
        else
            k = l - 1;
        stackinfo = new StackInfo(as, as1, ai, k);
        return stackinfo;
    }

    public static boolean isDebugging()
    {
        return sInDebugMode || DebuggerManager.isDebugging();
    }

    public static String getStackLevelChangeCommand(int i)
    {
        String s = "";
        if(i < 0)
            s = (new StringBuilder()).append("dbdown(").append(-i).append(");").toString();
        else
        if(i > 0)
            s = (new StringBuilder()).append("dbup(").append(i).append(");").toString();
        return s;
    }

    public static int getStopIfErrorState()
        throws IllegalStateException
    {
        return getStopIfState(1);
    }

    public static String[] getStopIfErrorIdentifiers()
        throws IllegalStateException
    {
        return GlobalBreakpointState.getStopIfErrorIdentifiers();
    }

    public static int getStopIfCaughtErrorState()
        throws IllegalStateException
    {
        return getStopIfState(4);
    }

    public static String[] getStopIfCaughtErrorIdentifiers()
        throws IllegalStateException
    {
        return GlobalBreakpointState.getStopIfCaughtErrorIdentifiers();
    }

    public static int getStopIfWarningState()
        throws IllegalStateException
    {
        return getStopIfState(2);
    }

    public static String[] getStopIfWarningIdentifiers()
        throws IllegalStateException
    {
        return GlobalBreakpointState.getStopIfWarningIdentifiers();
    }

    public static int getStopIfNanInfState()
        throws IllegalStateException
    {
        return getStopIfState(8);
    }

    private static int getStopIfState(int i)
    {
        boolean flag = false;
        String as[] = null;
        switch(i)
        {
        case 1: // '\001'
            flag = GlobalBreakpointState.getStopIfErrorState();
            as = GlobalBreakpointState.getStopIfErrorIdentifiers();
            break;

        case 4: // '\004'
            flag = GlobalBreakpointState.getStopIfCaughtErrorState();
            as = GlobalBreakpointState.getStopIfCaughtErrorIdentifiers();
            break;

        case 2: // '\002'
            flag = GlobalBreakpointState.getStopIfWarningState();
            as = GlobalBreakpointState.getStopIfWarningIdentifiers();
            break;

        case 8: // '\b'
            flag = GlobalBreakpointState.getStopIfNanInfState();
            break;
        }
        if(!flag)
            return 0;
        return as == null ? 1 : 2;
    }

    public static boolean isGraphicalDebuggingEnabled()
    {
        return Prefs.getBooleanPref("EditorGraphicalDebugging", true);
    }

    public static boolean isMatlabKeyboardMode()
    {
        return sInKeyboardMode;
    }

    public static boolean isBlacklisted(String s)
    {
        return LIVE_EDITOR_EVALUATION_HELPER_FILENAME_PATTERN.matcher(s).find();
    }

    public static StackInfo getMatlabStackInfo()
        throws IllegalStateException
    {
        if(sDebugModeSet)
            return sWS_SCOPEStackInfo;
        else
            throw new IllegalStateException(illegalStateErrorMsg);
    }

    public void initFileBreakpoints(String s)
    {
        if(sMatlab != null && fCompletionObserver != null)
        {
            String s1 = (new StringBuilder()).append("mdbstatus ('").append(s).append("')").toString();
            sMatlab.eval(s1, new DBStatusDBStackCallback(1, s, fCompletionObserver), 512);
        }
    }

    public static void requeryBreakpoints(String s)
    {
        if(sMatlab != null)
        {
            String s1 = prepareFilePath(s);
            String s2 = (new StringBuilder()).append("mdbstatus ('").append(s1).append("')").toString();
            sMatlab.eval(s2, new DBStatusDBStackCallback(1), 512);
        }
    }

    private static String prepareFilePath(String s)
    {
        return StringUtils.quoteSingleQuotes(s);
    }

    public static void doPause()
    {
        setPausing(true);
        MVM mvm = MvmFactory.getCurrentMVM();
        mvm.breakInDebugger();
    }

    private static synchronized void setPausing(boolean flag)
    {
        sIsPausing.set(flag);
        if(flag)
            DEFAULT_MATLAB_PAUSE_OBSERVER.doPause();
    }

    public static synchronized boolean isMatlabPausing()
    {
        return sIsPausing.get();
    }

    public static void dbCommand(int i)
    {
        dbCommand(i, null, 0);
    }

    public static void dbCommandNoEcho(int i)
    {
        commandSwitchyard(i, null, 0, false);
    }

    public static void dbCommand(int i, String s)
    {
        dbCommand(i, s, 0);
    }

    public static void dbCommand(int i, int j)
    {
        dbCommand(i, " ", j);
    }

    public static void dbCommand(int i, String s, int j)
    {
        commandSwitchyard(i, s, j, true);
    }

    private static void commandSwitchyard(int i, String s, int j, boolean flag)
    {
        if(sMatlab == null)
            return;
        switch(i)
        {
        default:
            break;

        case 9: // '\t'
            if(s != null && j >= 0)
            {
                PositionalBreakpoint positionalbreakpoint = new PositionalBreakpoint(j, new File(s));
                setBreakpoint(positionalbreakpoint, null);
            }
            break;

        case 6: // '\006'
            if(s != null && j >= 0)
            {
                PositionalBreakpoint positionalbreakpoint1 = new PositionalBreakpoint(j, new File(s));
                clearBreakpoint(positionalbreakpoint1, null);
            }
            break;

        case 8: // '\b'
            BreakpointBase.clearAllBreakpoints();
            break;

        case 7: // '\007'
            PositionalBreakpoint.clearAllBreakpoints(s);
            break;

        case 1: // '\001'
            doStep(flag);
            break;

        case 2: // '\002'
            doStepIn(flag);
            break;

        case 3: // '\003'
            doStepOut(flag);
            break;

        case 4: // '\004'
            doDBCont(flag);
            break;

        case 5: // '\005'
            doDBQuit();
            break;

        case 11: // '\013'
            doDBQuitAll();
            break;

        case 10: // '\n'
            doChangeWorkspace(j);
            break;
        }
    }

    private static void setInDebugMode(boolean flag)
    {
        sDebugModeSet = true;
        if(flag != sInDebugMode)
        {
            sInDebugMode = flag;
            if(!sInDebugMode)
                sInKeyboardMode = false;
            DEFAULT_MATLAB_DEBUG_OBSERVER.doDebugMode(sInDebugMode);
        }
    }

    private static Logger initializeLogger()
    {
        Logger logger = Logger.getLogger(com/mathworks/mlservices/MatlabDebugServices.getCanonicalName());
        logger.setLevel(Level.OFF);
        return logger;
    }

    public static void enableLogging()
    {
        LOGGER.setLevel(Level.ALL);
        if(LOGGER.getHandlers().length < 1)
            LOGGER.addHandler(LOGGER_HANDLER);
    }

    public static void disableLogging()
    {
        LOGGER.removeHandler(LOGGER_HANDLER);
        LOGGER.setLevel(Level.OFF);
    }

    private static void doChangeWorkspace(int i)
    {
        String s = "";
        s = getStackLevelChangeCommand(i);
        if(sMatlab != null)
            if(i != 0)
            {
                sMatlab.evalNoOutput(s);
            } else
            {
                MVM mvm = MvmFactory.getCurrentMVM();
                executeDBStack(mvm, STACK_DISPATCH);
            }
    }

    private static void doDBQuit()
    {
        MLExecuteServices.consoleEval(getIfDebugModeCommand("dbquit"), 1024);
    }

    private static void doDBQuitAll()
    {
        MLExecuteServices.consoleEval(getIfDebugModeCommand("dbquit all"), 1024);
    }

    private static void doDBCont(boolean flag)
    {
        if(flag)
            MLExecuteServices.consoleEval(getIfDebugModeCommand("dbcont"));
        else
            MLExecuteServices.consoleEval(getIfDebugModeCommand("dbcont"), 1024);
    }

    public static void setBreakpoint(BreakpointBase breakpointbase, CompletionObserver completionobserver)
    {
        if(breakpointbase == null)
        {
            return;
        } else
        {
            breakpointbase.set(completionobserver);
            return;
        }
    }

    public static void clearBreakpoint(BreakpointBase breakpointbase, CompletionObserver completionobserver)
    {
        if(breakpointbase == null)
        {
            return;
        } else
        {
            breakpointbase.clear(completionobserver);
            return;
        }
    }

    public static void debugCommandOnTheFly(String s, Object aobj[], boolean flag, CompletionObserver completionobserver)
    {
        if(!$assertionsDisabled && Matlab.isStandaloneMode())
        {
            throw new AssertionError("Breakpoints can only be set if MATLAB is not in standalone mode.");
        } else
        {
            MatlabMCR matlabmcr = MatlabMCRFactory.getForCurrentMCR();
            matlabmcr.whenMatlabReady(new Runnable(flag, aobj, s, completionobserver) {

                public void run()
                {
                    Object obj = null;
                    int i = 0;
                    try
                    {
                        if(hasOutput && arguments != null)
                            obj = MatlabMCR.mtFeval(functionName, arguments, 1);
                        else
                        if(hasOutput)
                            obj = MatlabMCR.mtEval(functionName, 1);
                        else
                        if(arguments != null)
                            MatlabMCR.mtFeval(functionName, arguments, 0);
                        else
                            MatlabMCR.mtEval(functionName, 0);
                    }
                    catch(Exception exception)
                    {
                        i = 2;
                    }
                    if(observer != null)
                        observer.completed(i, obj);
                }

                final boolean val$hasOutput;
                final Object val$arguments[];
                final String val$functionName;
                final CompletionObserver val$observer;

            
            {
                hasOutput = flag;
                arguments = aobj;
                functionName = s;
                observer = completionobserver;
                super();
            }
            }
);
            return;
        }
    }

    private static void doStep(boolean flag)
    {
        if(flag)
            MLExecuteServices.consoleEval(getIfDebugModeCommand("dbstep"));
        else
            MLExecuteServices.consoleEval(getIfDebugModeCommand("dbstep"), 1024);
    }

    private static void doStepIn(boolean flag)
    {
        if(flag)
            MLExecuteServices.consoleEval(getIfDebugModeCommand("dbstep in"));
        else
            MLExecuteServices.consoleEval(getIfDebugModeCommand("dbstep in"), 1024);
    }

    private static void doStepOut(boolean flag)
    {
        if(flag)
            MLExecuteServices.consoleEval(getIfDebugModeCommand("dbstep out"));
        else
            MLExecuteServices.consoleEval(getIfDebugModeCommand("dbstep out"), 1024);
    }

    private static String getIfDebugModeCommand(String s)
    {
        return (new StringBuilder()).append("if system_dependent('IsDebugMode')==1, ").append(s).append("; end").toString();
    }

    public static void submitRequest(MVM mvm, MatlabFevalRequest matlabfevalrequest, CompletionObserver completionobserver)
    {
        MatlabExecutor matlabexecutor = mvm.getExecutor();
        FutureFevalResult futurefevalresult = matlabexecutor.submit(matlabfevalrequest);
        futurefevalresult.runWhenDone(new Runnable(futurefevalresult, completionobserver) {

            public void run()
            {
                try
                {
                    Object obj = result.get();
                    observer.completed(0, obj);
                }
                catch(Object obj1)
                {
                    ((Exception) (obj1)).printStackTrace();
                    observer.completed(2, null);
                }
            }

            final FutureFevalResult val$result;
            final CompletionObserver val$observer;

            
            {
                result = futurefevalresult;
                observer = completionobserver;
                super();
            }
        }
);
    }

    public static final int NEVER = 0;
    public static final int ALWAYS = 1;
    public static final int USE_IDS = 2;
    public static final int DBSTEP = 1;
    public static final int DBSTEPIN = 2;
    public static final int DBSTEPOUT = 3;
    public static final int DBCONT = 4;
    public static final int DBQUIT = 5;
    public static final int DBCLEAR = 6;
    public static final int DBCLEARFILE = 7;
    public static final int DBCLEARALL = 8;
    public static final int DBSTOP = 9;
    public static final int DBCHANGEWORKSPACECONTEXT = 10;
    public static final int DBQUITALL = 11;
    public static final String MATLAB_BASE_WS = "<Base>";
    public static final int CURRENT_WORKSPACE_CONTEXT = 0;
    private static final String LIVE_EDITOR_EVALUATION_HELPER_FILENAME_REGEX = "LiveEditorEvaluationHelper.+\\.m";
    private static final Pattern LIVE_EDITOR_EVALUATION_HELPER_FILENAME_PATTERN = Pattern.compile("LiveEditorEvaluationHelper.+\\.m");
    private static final int BREAKPOINTS_REPLY = 1;
    private static final int STACK_MESSAGE = 2;
    private static Object sInterestCookies[];
    private static final DebugDispatch DEBUG_DISPATCH;
    private static final StackDispatch STACK_DISPATCH = new StackDispatch();
    private static final StackCallback STACK_CALLBACK;
    private static Matlab sMatlab;
    private static boolean sInDebugMode = false;
    private static boolean sDebugModeSet = false;
    private static final AtomicBoolean sIsPausing = new AtomicBoolean(false);
    private static StackInfo sWS_SCOPEStackInfo = null;
    private MatlabDebugObserver fCompletionObserver;
    private static final DefaultMatlabDebugObserver DEFAULT_MATLAB_DEBUG_OBSERVER;
    private static final DefaultMatlabPauseObserver DEFAULT_MATLAB_PAUSE_OBSERVER = new DefaultMatlabPauseObserver();
    private static final CtrlCListener CTRL_C_LISTENER;
    private static final BusyExecutionListener BUSY_EXECUTION_LISTENER;
    private static DebugEventTranslator sEventTranslator = null;
    private static final Logger LOGGER = initializeLogger();
    private static final Handler LOGGER_HANDLER = new ConsoleHandler();
    private static String illegalStateErrorMsg = "MatlabDebugServices has not yet initialized.";
    private static final String sDBStackString = "dbstack";
    private static final Object sDBStackArgs[] = {
        "-completenames"
    };
    private static volatile boolean sInKeyboardMode = false;
    private static boolean sMWDebugOverride = false;
    static final boolean $assertionsDisabled = !com/mathworks/mlservices/MatlabDebugServices.desiredAssertionStatus();

    static 
    {
        DEBUG_DISPATCH = new DebugDispatch();
        STACK_CALLBACK = new StackCallback();
        sMatlab = null;
        DEFAULT_MATLAB_DEBUG_OBSERVER = new DefaultMatlabDebugObserver();
        CTRL_C_LISTENER = new CtrlCListener();
        BUSY_EXECUTION_LISTENER = new BusyExecutionListener();
        if(Matlab.isMatlabAvailable() && !Matlab.isStandaloneMode())
            sMatlab = new Matlab();
        if(sMatlab != null && sInterestCookies == null)
        {
            GlobalBreakpointState.triggerRefresh(sMatlab, DEFAULT_MATLAB_DEBUG_OBSERVER);
            executeDBstack(sMatlab, new DBStatusDBStackCallback(2));
            sInterestCookies = new Object[9];
            sInterestCookies[0] = sMatlab.registerInterest(1, 0x4000000, DEBUG_DISPATCH);
            sInterestCookies[1] = sMatlab.registerInterest(1, 0x8000000, DEBUG_DISPATCH);
            sInterestCookies[2] = sMatlab.registerInterest(1, 0x2000000, DEBUG_DISPATCH);
            sInterestCookies[3] = sMatlab.registerInterest(1, 0x10000000, DEBUG_DISPATCH);
            sInterestCookies[4] = sMatlab.registerInterest(1, 0x80000000, DEBUG_DISPATCH);
            sInterestCookies[5] = sMatlab.registerInterest(1, 0x40000000, DEBUG_DISPATCH);
            sInterestCookies[6] = sMatlab.registerInterest(1, 0x20000000, DEBUG_DISPATCH);
            sInterestCookies[7] = sMatlab.registerInterest(3, 0x80000000, STACK_CALLBACK);
            sInterestCookies[8] = sMatlab.registerInterest(1, 0x1000000, DEBUG_DISPATCH);
            Matlab.addListener(CTRL_C_LISTENER);
            MLExecuteServices.addMLExecutionListener(BUSY_EXECUTION_LISTENER);
        } else
        if(Matlab.isStandaloneMode())
        {
            sInDebugMode = false;
            sDebugModeSet = true;
        }
        GlobalEventManager.addListener("shutdown", new GlobalEventListener() {

            public void actionPerformed(String s)
            {
                MLExecuteServices.removeMLExecutionListener(MatlabDebugServices.BUSY_EXECUTION_LISTENER);
                Matlab.removeListener(MatlabDebugServices.CTRL_C_LISTENER);
            }

        }
);
    }














}
