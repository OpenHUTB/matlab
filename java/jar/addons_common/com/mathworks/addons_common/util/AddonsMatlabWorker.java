// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   AddonsMatlabWorker.java

package com.mathworks.addons_common.util;

import com.mathworks.jmi.MatlabWorker;
import com.mathworks.mvm.MVM;
import com.mathworks.mvm.context.MvmContext;
import com.mathworks.mvm.exec.*;
import com.mathworks.util.Log;
import com.mathworks.util.event.GlobalEventListener;
import com.mathworks.util.event.GlobalEventManager;

public final class AddonsMatlabWorker extends MatlabWorker
{

    public AddonsMatlabWorker(String s, Object aobj[])
    {
        command = s;
        args = new Object[aobj.length];
        System.arraycopy(((Object) (aobj)), 0, ((Object) (args)), 0, aobj.length);
        addListenerToInterruptThreadOnMatlabShutdown(Thread.currentThread());
    }

    private void addListenerToInterruptThreadOnMatlabShutdown(final Thread currentThread)
    {
        GlobalEventManager.addListener("shutdown", new GlobalEventListener() {

            public void actionPerformed(String s)
            {
                currentThread.interrupt();
            }

            final Thread val$currentThread;
            final AddonsMatlabWorker this$0;

            
            {
                this$0 = AddonsMatlabWorker.this;
                currentThread = thread;
                super();
            }
        }
);
    }

    public Void runOnMatlabThread()
        throws Exception
    {
        return null;
    }

    public void runOnAWTEventDispatchThread(Void void1)
    {
    }

    public Object get()
        throws InterruptedException
    {
        try
        {
            MatlabExecutor matlabexecutor = MvmContext.get().getExecutor();
            MatlabFevalRequest matlabfevalrequest = new MatlabFevalRequest(command, Integer.valueOf(1), args);
            FutureFevalResult futurefevalresult = matlabexecutor.submit(matlabfevalrequest);
            return futurefevalresult.get();
        }
        catch(Exception exception)
        {
            Log.logException(exception);
        }
        return null;
    }

    public volatile void runOnAWTEventDispatchThread(Object obj)
    {
        runOnAWTEventDispatchThread((Void)obj);
    }

    public volatile Object runOnMatlabThread()
        throws Exception
    {
        return runOnMatlabThread();
    }

    private final Object args[];
    private final String command;
}
