// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   BooleanFunctionDelegate.java

package org.eclipse.xtext.xbase.lib.internal;

import com.google.common.base.Predicate;
import org.eclipse.xtext.xbase.lib.Functions;

public class BooleanFunctionDelegate
    implements Predicate
{

    public BooleanFunctionDelegate(org.eclipse.xtext.xbase.lib.Functions.Function1 delegate)
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

    public boolean apply(Object input)
    {
        Boolean result = (Boolean)_flddelegate.apply(input);
        return result.booleanValue();
    }

    private final org.eclipse.xtext.xbase.lib.Functions.Function1 _flddelegate;
}
