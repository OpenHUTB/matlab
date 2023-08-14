// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   KeyComparator.java

package org.eclipse.xtext.xbase.lib.internal;

import com.google.common.base.Preconditions;
import java.util.Comparator;
import org.eclipse.xtext.xbase.lib.Functions;

public final class KeyComparator
    implements Comparator
{

    public KeyComparator(org.eclipse.xtext.xbase.lib.Functions.Function1 keyFunction)
    {
        this.keyFunction = (org.eclipse.xtext.xbase.lib.Functions.Function1)Preconditions.checkNotNull(keyFunction, "keyFunction");
    }

    public int compare(Object a, Object b)
    {
        Comparable c1 = (Comparable)keyFunction.apply(a);
        Comparable c2 = (Comparable)keyFunction.apply(b);
        if(c1 == c2)
            return 0;
        if(c1 != null)
            return c1.compareTo(c2);
        else
            return -c2.compareTo(c1);
    }

    private final org.eclipse.xtext.xbase.lib.Functions.Function1 keyFunction;
}
