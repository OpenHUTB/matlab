// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   MLExecute.java

package com.mathworks.mlservices;


// Referenced classes of package com.mathworks.mlservices:
//            MatlabExecutionErrorHandler, MLExecutionListener

public interface MLExecute
{

    public abstract void executeCommand(String s);

    public abstract void executeCommand(String s, MatlabExecutionErrorHandler matlabexecutionerrorhandler);

    public abstract void consoleEval(String s);

    public abstract void consoleEval(String s, int i);

    public abstract void addMLExecutionListener(MLExecutionListener mlexecutionlistener);

    public abstract void removeMLExecutionListener(MLExecutionListener mlexecutionlistener);
}
