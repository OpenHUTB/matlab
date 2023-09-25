// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   MLExecutionEvent.java

package com.mathworks.mlservices;

import com.mathworks.jmi.Matlab;
import javax.swing.event.ChangeEvent;

public final class MLExecutionEvent extends ChangeEvent
{
    public static final class InterpretedStatus extends Enum
    {

        public static InterpretedStatus[] values()
        {
            return (InterpretedStatus[])$VALUES.clone();
        }

        public static InterpretedStatus valueOf(String s)
        {
            return (InterpretedStatus)Enum.valueOf(com/mathworks/mlservices/MLExecutionEvent$InterpretedStatus, s);
        }

        public static final InterpretedStatus UNSET;
        public static final InterpretedStatus INITIALIZING;
        public static final InterpretedStatus IDLE;
        public static final InterpretedStatus IDLE_AND_PROFILING;
        public static final InterpretedStatus BUSY;
        public static final InterpretedStatus BUSY_AND_PROFILING;
        public static final InterpretedStatus PAUSED;
        public static final InterpretedStatus AT_BREAKPOINT;
        public static final InterpretedStatus AWAITING_INPUT;
        public static final InterpretedStatus COMPLETING_BLOCK;
        public static final InterpretedStatus BANG;
        public static final InterpretedStatus BANG_FINISH;
        public static final InterpretedStatus START_EVAL;
        public static final InterpretedStatus DESKTOP_UP;
        public static final InterpretedStatus PROMPT_INSERT;
        public static final InterpretedStatus PROFILER_ON;
        public static final InterpretedStatus PROFILER_OFF;
        private static final InterpretedStatus $VALUES[];

        static 
        {
            UNSET = new InterpretedStatus("UNSET", 0);
            INITIALIZING = new InterpretedStatus("INITIALIZING", 1);
            IDLE = new InterpretedStatus("IDLE", 2);
            IDLE_AND_PROFILING = new InterpretedStatus("IDLE_AND_PROFILING", 3);
            BUSY = new InterpretedStatus("BUSY", 4);
            BUSY_AND_PROFILING = new InterpretedStatus("BUSY_AND_PROFILING", 5);
            PAUSED = new InterpretedStatus("PAUSED", 6);
            AT_BREAKPOINT = new InterpretedStatus("AT_BREAKPOINT", 7);
            AWAITING_INPUT = new InterpretedStatus("AWAITING_INPUT", 8);
            COMPLETING_BLOCK = new InterpretedStatus("COMPLETING_BLOCK", 9);
            BANG = new InterpretedStatus("BANG", 10);
            BANG_FINISH = new InterpretedStatus("BANG_FINISH", 11);
            START_EVAL = new InterpretedStatus("START_EVAL", 12);
            DESKTOP_UP = new InterpretedStatus("DESKTOP_UP", 13);
            PROMPT_INSERT = new InterpretedStatus("PROMPT_INSERT", 14);
            PROFILER_ON = new InterpretedStatus("PROFILER_ON", 15);
            PROFILER_OFF = new InterpretedStatus("PROFILER_OFF", 16);
            $VALUES = (new InterpretedStatus[] {
                UNSET, INITIALIZING, IDLE, IDLE_AND_PROFILING, BUSY, BUSY_AND_PROFILING, PAUSED, AT_BREAKPOINT, AWAITING_INPUT, COMPLETING_BLOCK, 
                BANG, BANG_FINISH, START_EVAL, DESKTOP_UP, PROMPT_INSERT, PROFILER_ON, PROFILER_OFF
            });
        }

        private InterpretedStatus(String s, int i)
        {
            super(s, i);
        }
    }


    private MLExecutionEvent(Object obj, int i, InterpretedStatus interpretedstatus)
    {
        super(obj);
        fPrompt = Matlab.NO_PROMPT;
        fLastNonNullPrompt = Matlab.BASE_PROMPT;
        fBlock = 0;
        fRawStatus = -1;
        fProfiling = false;
        fNonMATLABStatus = InterpretedStatus.UNSET;
        fInterpretedStatus = InterpretedStatus.UNSET;
        setStatus(i, interpretedstatus);
    }

    private void extractStatus()
    {
        static class _cls1
        {

            static final int $SwitchMap$com$mathworks$mlservices$MLExecutionEvent$InterpretedStatus[];

            static 
            {
                $SwitchMap$com$mathworks$mlservices$MLExecutionEvent$InterpretedStatus = new int[InterpretedStatus.values().length];
                try
                {
                    $SwitchMap$com$mathworks$mlservices$MLExecutionEvent$InterpretedStatus[InterpretedStatus.START_EVAL.ordinal()] = 1;
                }
                catch(NoSuchFieldError nosuchfielderror) { }
                try
                {
                    $SwitchMap$com$mathworks$mlservices$MLExecutionEvent$InterpretedStatus[InterpretedStatus.PROFILER_ON.ordinal()] = 2;
                }
                catch(NoSuchFieldError nosuchfielderror1) { }
                try
                {
                    $SwitchMap$com$mathworks$mlservices$MLExecutionEvent$InterpretedStatus[InterpretedStatus.PROFILER_OFF.ordinal()] = 3;
                }
                catch(NoSuchFieldError nosuchfielderror2) { }
                try
                {
                    $SwitchMap$com$mathworks$mlservices$MLExecutionEvent$InterpretedStatus[InterpretedStatus.AT_BREAKPOINT.ordinal()] = 4;
                }
                catch(NoSuchFieldError nosuchfielderror3) { }
                try
                {
                    $SwitchMap$com$mathworks$mlservices$MLExecutionEvent$InterpretedStatus[InterpretedStatus.AWAITING_INPUT.ordinal()] = 5;
                }
                catch(NoSuchFieldError nosuchfielderror4) { }
                try
                {
                    $SwitchMap$com$mathworks$mlservices$MLExecutionEvent$InterpretedStatus[InterpretedStatus.COMPLETING_BLOCK.ordinal()] = 6;
                }
                catch(NoSuchFieldError nosuchfielderror5) { }
                try
                {
                    $SwitchMap$com$mathworks$mlservices$MLExecutionEvent$InterpretedStatus[InterpretedStatus.IDLE.ordinal()] = 7;
                }
                catch(NoSuchFieldError nosuchfielderror6) { }
                try
                {
                    $SwitchMap$com$mathworks$mlservices$MLExecutionEvent$InterpretedStatus[InterpretedStatus.IDLE_AND_PROFILING.ordinal()] = 8;
                }
                catch(NoSuchFieldError nosuchfielderror7) { }
                try
                {
                    $SwitchMap$com$mathworks$mlservices$MLExecutionEvent$InterpretedStatus[InterpretedStatus.PAUSED.ordinal()] = 9;
                }
                catch(NoSuchFieldError nosuchfielderror8) { }
                try
                {
                    $SwitchMap$com$mathworks$mlservices$MLExecutionEvent$InterpretedStatus[InterpretedStatus.BANG.ordinal()] = 10;
                }
                catch(NoSuchFieldError nosuchfielderror9) { }
                try
                {
                    $SwitchMap$com$mathworks$mlservices$MLExecutionEvent$InterpretedStatus[InterpretedStatus.BANG_FINISH.ordinal()] = 11;
                }
                catch(NoSuchFieldError nosuchfielderror10) { }
            }
        }

        if(fNonMATLABStatus != InterpretedStatus.UNSET)
            switch(_cls1..SwitchMap.com.mathworks.mlservices.MLExecutionEvent.InterpretedStatus[fNonMATLABStatus.ordinal()])
            {
            case 1: // '\001'
                fRawStatus = fRawStatus | 0xff00;
                fRawStatus = fRawStatus & 0xffffff00;
                break;

            case 2: // '\002'
                fProfiling = true;
                break;

            case 3: // '\003'
                fProfiling = false;
                break;
            }
        int i = fPrompt;
        fPrompt = Matlab.getInputRequester(fRawStatus);
        if(i != Matlab.NO_PROMPT)
            fLastNonNullPrompt = i;
        fBlock = Matlab.getCodeBlockStatus(fRawStatus);
    }

    public synchronized int getRawStatus()
    {
        return fRawStatus;
    }

    public synchronized boolean fromInterpreter()
    {
        switch(_cls1..SwitchMap.com.mathworks.mlservices.MLExecutionEvent.InterpretedStatus[getInterpretedStatus().ordinal()])
        {
        case 4: // '\004'
        case 5: // '\005'
        case 6: // '\006'
        case 7: // '\007'
        case 8: // '\b'
        case 9: // '\t'
            return true;
        }
        return false;
    }

    public synchronized boolean getHGBusy()
    {
        int i = getHGStatus();
        return (i & 6) != 0;
    }

    public synchronized int getHGStatus()
    {
        return Matlab.getHGStatus(fRawStatus);
    }

    public static MLExecutionEvent getInstance(Object obj, int i, InterpretedStatus interpretedstatus)
    {
        if(sTheEvent == null)
            sTheEvent = new MLExecutionEvent(obj, i, interpretedstatus);
        return sTheEvent;
    }

    public synchronized InterpretedStatus getInterpretedStatus()
    {
        if(fInterpretedStatus == InterpretedStatus.UNSET)
            fInterpretedStatus = interpretStatus();
        return fInterpretedStatus;
    }

    private InterpretedStatus interpretStatus()
    {
        switch(_cls1..SwitchMap.com.mathworks.mlservices.MLExecutionEvent.InterpretedStatus[fNonMATLABStatus.ordinal()])
        {
        case 1: // '\001'
        case 10: // '\n'
            if(fProfiling)
                return InterpretedStatus.BUSY_AND_PROFILING;
            else
                return InterpretedStatus.BUSY;

        case 11: // '\013'
            fNonMATLABStatus = InterpretedStatus.UNSET;
            break;
        }
        if(fNonMATLABStatus != InterpretedStatus.UNSET)
            return fNonMATLABStatus;
        if(fBlock == 1)
            return InterpretedStatus.COMPLETING_BLOCK;
        if(fPrompt == Matlab.NO_PROMPT)
            if(fProfiling)
                return InterpretedStatus.BUSY_AND_PROFILING;
            else
                return InterpretedStatus.BUSY;
        if(fPrompt == Matlab.DEBUG_PROMPT)
            return InterpretedStatus.AT_BREAKPOINT;
        if(fPrompt == Matlab.PAUSE_PROMPT)
            return InterpretedStatus.PAUSED;
        if(fPrompt == Matlab.INPUT_PROMPT || fPrompt == Matlab.KEYBOARD_PROMPT)
            return InterpretedStatus.AWAITING_INPUT;
        if(fProfiling)
            return InterpretedStatus.IDLE_AND_PROFILING;
        else
            return InterpretedStatus.IDLE;
    }

    public synchronized boolean isAtKeyboard()
    {
        return fPrompt == Matlab.KEYBOARD_PROMPT;
    }

    public synchronized boolean isAwaitingInput()
    {
        return fPrompt == Matlab.INPUT_PROMPT;
    }

    public synchronized boolean isEnteringInputMode()
    {
        return fPrompt == Matlab.INPUT_PROMPT && fPrompt != fLastNonNullPrompt;
    }

    public synchronized boolean isEnteringKeyboardMode()
    {
        return fPrompt == Matlab.KEYBOARD_PROMPT && fPrompt != fLastNonNullPrompt;
    }

    public synchronized boolean isCommandBusy()
    {
        return getInterpretedStatus() == InterpretedStatus.BUSY || getInterpretedStatus() == InterpretedStatus.BUSY_AND_PROFILING;
    }

    public synchronized boolean isCommandInProgress()
    {
        return !isCommandOver();
    }

    public synchronized boolean isCommandOver()
    {
        InterpretedStatus interpretedstatus = getInterpretedStatus();
        return interpretedstatus == InterpretedStatus.IDLE || interpretedstatus == InterpretedStatus.IDLE_AND_PROFILING;
    }

    public synchronized boolean isIncomplete()
    {
        return getInterpretedStatus() == InterpretedStatus.COMPLETING_BLOCK;
    }

    public synchronized void setStatus(int i, InterpretedStatus interpretedstatus)
    {
        fInterpretedStatus = InterpretedStatus.UNSET;
        fNonMATLABStatus = interpretedstatus;
        if(interpretedstatus == InterpretedStatus.UNSET)
        {
            if(i == -256)
                i = (Matlab.getInputRequester(i) & 0xff) << 8;
            int j = Matlab.getInputRequester(i);
            if((Matlab.getHGStatus(i) & 0x40) == 0)
                i |= fHGStatus & 0x3f000000;
            i = i & 0xffff00ff | (j & 0xff) << 8;
            fHGStatus = i;
            fRawStatus = i;
            fNonMATLABStatus = InterpretedStatus.UNSET;
        }
        extractStatus();
    }

    public static final int NO_NON_MATLAB_STATUS = -1;
    private int fPrompt;
    private int fLastNonNullPrompt;
    private int fBlock;
    private int fRawStatus;
    private boolean fProfiling;
    private InterpretedStatus fNonMATLABStatus;
    private InterpretedStatus fInterpretedStatus;
    private static MLExecutionEvent sTheEvent;
    private int fHGStatus;
    private static final int HG_VALID = 64;
}
