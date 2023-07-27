// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   CollectionLiterals.java

package org.eclipse.xtext.xbase.lib;

import com.google.common.collect.*;
import com.google.common.primitives.Ints;
import java.util.*;

// Referenced classes of package org.eclipse.xtext.xbase.lib:
//            Pair

public class CollectionLiterals
{

    public CollectionLiterals()
    {
    }

    public static List emptyList()
    {
        return Collections.emptyList();
    }

    public static Set emptySet()
    {
        return Collections.emptySet();
    }

    public static Map emptyMap()
    {
        return Collections.emptyMap();
    }

    public static transient List newImmutableList(Object elements[])
    {
        return ImmutableList.copyOf(elements);
    }

    public static transient Set newImmutableSet(Object elements[])
    {
        return ImmutableSet.copyOf(elements);
    }

    public static transient Map newImmutableMap(Pair entries[])
    {
        if(entries.length == 0)
            return emptyMap();
        com.google.common.collect.ImmutableMap.Builder builder = ImmutableMap.builder();
        Pair apair[] = entries;
        int i = apair.length;
        for(int j = 0; j < i; j++)
        {
            Pair entry = apair[j];
            builder.put(entry.getKey(), entry.getValue());
        }

        return builder.build();
    }

    public static ArrayList newArrayList()
    {
        return new ArrayList();
    }

    public static transient ArrayList newArrayList(Object initial[])
    {
        if(initial.length > 0)
            return Lists.newArrayList(initial);
        else
            return newArrayList();
    }

    public static LinkedList newLinkedList()
    {
        return new LinkedList();
    }

    public static transient LinkedList newLinkedList(Object initial[])
    {
        if(initial.length > 0)
            return Lists.newLinkedList(Arrays.asList(initial));
        else
            return newLinkedList();
    }

    public static HashSet newHashSet()
    {
        return new HashSet();
    }

    public static transient HashSet newHashSet(Object initial[])
    {
        if(initial.length > 0)
            return Sets.newHashSet(initial);
        else
            return newHashSet();
    }

    public static LinkedHashSet newLinkedHashSet()
    {
        return new LinkedHashSet();
    }

    public static transient LinkedHashSet newLinkedHashSet(Object initial[])
    {
        if(initial.length > 0)
            return Sets.newLinkedHashSet(Arrays.asList(initial));
        else
            return newLinkedHashSet();
    }

    public static TreeSet newTreeSet(Comparator comparator)
    {
        return new TreeSet(comparator);
    }

    public static transient TreeSet newTreeSet(Comparator comparator, Object initial[])
    {
        TreeSet result = new TreeSet(comparator);
        if(initial.length > 0)
            result.addAll(Arrays.asList(initial));
        return result;
    }

    public static HashMap newHashMap()
    {
        return new HashMap();
    }

    public static transient HashMap newHashMap(Pair initial[])
    {
        if(initial.length > 0)
        {
            HashMap result = new HashMap(capacity(initial.length));
            putAll(result, initial);
            return result;
        } else
        {
            return newHashMap();
        }
    }

    public static LinkedHashMap newLinkedHashMap()
    {
        return new LinkedHashMap();
    }

    public static transient LinkedHashMap newLinkedHashMap(Pair initial[])
    {
        if(initial.length > 0)
        {
            LinkedHashMap result = new LinkedHashMap(capacity(initial.length));
            putAll(result, initial);
            return result;
        } else
        {
            return newLinkedHashMap();
        }
    }

    private static int capacity(int initialSize)
    {
        if(initialSize < 3)
            return initialSize + 1;
        if(initialSize < 0x40000000)
            return initialSize + initialSize / 3;
        else
            return 0x7fffffff;
    }

    public static TreeMap newTreeMap(Comparator comparator)
    {
        return new TreeMap(comparator);
    }

    public static transient TreeMap newTreeMap(Comparator comparator, Pair initial[])
    {
        TreeMap result = new TreeMap(comparator);
        putAll(result, initial);
        return result;
    }

    private static transient void putAll(Map result, Pair entries[])
    {
        Pair apair[] = entries;
        int i = apair.length;
        for(int j = 0; j < i; j++)
        {
            Pair entry = apair[j];
            if(result.containsKey(entry.getKey()))
                throw new IllegalArgumentException((new StringBuilder()).append("duplicate key: ").append(entry.getKey()).toString());
            result.put(entry.getKey(), entry.getValue());
        }

    }
}
