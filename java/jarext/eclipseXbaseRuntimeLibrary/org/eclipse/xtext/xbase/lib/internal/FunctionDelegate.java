// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   FunctionDelegate.java

package org.eclipse.xtext.xbase.lib.internal;

import com.google.common.base.Function;
import org.eclipse.xtext.xbase.lib.Functions;

public class FunctionDelegate
    implements Function
{

    public FunctionDelegate(org.eclipse.xtext.xbase.lib.Functions.Function1 delegate)
    {
        if(delegate == null)
        {
            throw new NullPointerException("delegate");
        } else
        {
            _flddelegate = delegate;
            return;
        }
    }

    public Object apply(Object input)
    {
        Object result = _flddelegate.apply(input);
        return result;
    }

    private final org.eclipse.xtext.xbase.lib.Functions.Function1 _flddelegate;
}
