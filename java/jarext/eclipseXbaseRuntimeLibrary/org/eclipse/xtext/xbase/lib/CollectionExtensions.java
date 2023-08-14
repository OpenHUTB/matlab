// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   CollectionExtensions.java

package org.eclipse.xtext.xbase.lib;

import com.google.common.collect.*;
import java.util.*;

public class CollectionExtensions
{

    public CollectionExtensions()
    {
    }

    public static boolean operator_add(Collection collection, Object value)
    {
        return collection.add(value);
    }

    public static boolean operator_add(Collection collection, Iterable newElements)
    {
        return addAll(collection, newElements);
    }

    public static boolean operator_remove(Collection collection, Object value)
    {
        return collection.remove(value);
    }

    public static boolean operator_remove(Collection collection, Collection newElements)
    {
        return removeAll(collection, newElements);
    }

    public static List unmodifiableView(List list)
    {
        return Collections.unmodifiableList(list);
    }

    public static Collection unmodifiableView(Collection collection)
    {
        return Collections.unmodifiableCollection(collection);
    }

    public static Set unmodifiableView(Set set)
    {
        return Collections.unmodifiableSet(set);
    }

    public static SortedSet unmodifiableView(SortedSet set)
    {
        return Collections.unmodifiableSortedSet(set);
    }

    public static Map unmodifiableView(Map map)
    {
        return Collections.unmodifiableMap(map);
    }

    public static SortedMap unmodifiableView(SortedMap map)
    {
        return Collections.unmodifiableSortedMap(map);
    }

    public static List immutableCopy(List list)
    {
        return ImmutableList.copyOf(list);
    }

    public static Set immutableCopy(Set set)
    {
        return ImmutableSet.copyOf(set);
    }

    public static SortedSet immutableCopy(SortedSet set)
    {
        return ImmutableSortedSet.copyOfSorted(set);
    }

    public static Map immutableCopy(Map map)
    {
        return ImmutableMap.copyOf(map);
    }

    public static SortedMap immutableCopy(SortedMap map)
    {
        return ImmutableSortedMap.copyOfSorted(map);
    }

    public static transient boolean addAll(Collection collection, Object elements[])
    {
        return collection.addAll(Arrays.asList(elements));
    }

    public static boolean addAll(Collection collection, Iterable elements)
    {
        return Iterables.addAll(collection, elements);
    }

    public static transient boolean removeAll(Collection collection, Object elements[])
    {
        return collection.removeAll(Arrays.asList(elements));
    }

    public static boolean removeAll(Collection collection, Collection elements)
    {
        return Iterables.removeAll(collection, elements);
    }

    public static boolean removeAll(Collection collection, Iterable elements)
    {
        return Iterables.removeAll(collection, Sets.newHashSet(elements));
    }
}
