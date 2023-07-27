// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   ToStringContext.java

package org.eclipse.xtext.xbase.lib.util;

import java.util.IdentityHashMap;

class ToStringContext
{

    ToStringContext()
    {
    }

    public boolean startProcessing(Object obj)
    {
        return ((IdentityHashMap)currentlyProcessed.get()).put(obj, Boolean.TRUE) == null;
    }

    public void endProcessing(Object obj)
    {
        ((IdentityHashMap)currentlyProcessed.get()).remove(obj);
    }

    public static final ToStringContext INSTANCE = new ToStringContext();
    private static final ThreadLocal currentlyProcessed = new ThreadLocal() {

        public IdentityHashMap initialValue()
        {
            return new IdentityHashMap();
        }

        public volatile Object initialValue()
        {
            return initialValue();
        }

    }
;

}
