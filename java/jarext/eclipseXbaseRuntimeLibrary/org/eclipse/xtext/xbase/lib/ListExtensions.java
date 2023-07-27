// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   ListExtensions.java

package org.eclipse.xtext.xbase.lib;

import com.google.common.collect.Lists;
import java.util.*;
import org.eclipse.xtext.xbase.lib.internal.FunctionDelegate;
import org.eclipse.xtext.xbase.lib.internal.KeyComparator;

// Referenced classes of package org.eclipse.xtext.xbase.lib:
//            Functions

public class ListExtensions
{

    public ListExtensions()
    {
    }

    public static List sortInplace(List list)
    {
        Collections.sort(list);
        return list;
    }

    public static List sortInplace(List list, Comparator comparator)
    {
        Collections.sort(list, comparator);
        return list;
    }

    public static List sortInplaceBy(List list, Functions.Function1 key)
    {
        if(key == null)
        {
            throw new NullPointerException("key");
        } else
        {
            Collections.sort(list, new KeyComparator(key));
            return list;
        }
    }

    public static List reverseView(List list)
    {
        return Lists.reverse(list);
    }

    public static List reverse(List list)
    {
        Collections.reverse(list);
        return list;
    }

    public static List map(List original, Functions.Function1 transformation)
    {
        return Lists.transform(original, new FunctionDelegate(transformation));
    }
}
