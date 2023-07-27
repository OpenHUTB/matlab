// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   MapExtensions.java

package org.eclipse.xtext.xbase.lib;

import com.google.common.base.Objects;
import com.google.common.base.Predicate;
import com.google.common.collect.Iterables;
import com.google.common.collect.Maps;
import java.util.*;
import org.eclipse.xtext.xbase.lib.internal.FunctionDelegate;
import org.eclipse.xtext.xbase.lib.internal.UnmodifiableMergingMapView;

// Referenced classes of package org.eclipse.xtext.xbase.lib:
//            Pair, Procedures, Functions

public class MapExtensions
{

    public MapExtensions()
    {
    }

    public static void forEach(Map map, Procedures.Procedure2 procedure)
    {
        if(procedure == null)
            throw new NullPointerException("procedure");
        java.util.Map.Entry entry;
        for(Iterator iterator = map.entrySet().iterator(); iterator.hasNext(); procedure.apply(entry.getKey(), entry.getValue()))
            entry = (java.util.Map.Entry)iterator.next();

    }

    public static void forEach(Map map, Procedures.Procedure3 procedure)
    {
        if(procedure == null)
            throw new NullPointerException("procedure");
        int i = 0;
        Iterator iterator = map.entrySet().iterator();
        do
        {
            if(!iterator.hasNext())
                break;
            java.util.Map.Entry entry = (java.util.Map.Entry)iterator.next();
            procedure.apply(entry.getKey(), entry.getValue(), Integer.valueOf(i));
            if(i != 0x7fffffff)
                i++;
        } while(true);
    }

    public static Map filter(Map original, Functions.Function2 predicate)
    {
        if(predicate == null)
            throw new NullPointerException("predicate");
        else
            return Maps.filterEntries(original, new Predicate(predicate) {

                public boolean apply(java.util.Map.Entry input)
                {
                    Boolean result = (Boolean)predicate.apply(input.getKey(), input.getValue());
                    return result.booleanValue();
                }

                public volatile boolean apply(Object obj)
                {
                    return apply((java.util.Map.Entry)obj);
                }

                final Functions.Function2 val$predicate;

            
            {
                predicate = function2;
                super();
            }
            }
);
    }

    public static Object operator_add(Map map, Pair entry)
    {
        return map.put(entry.getKey(), entry.getValue());
    }

    public static void operator_add(Map outputMap, Map inputMap)
    {
        outputMap.putAll(inputMap);
    }

    public static Map operator_plus(Map left, Pair right)
    {
        return union(left, Collections.singletonMap(right.getKey(), right.getValue()));
    }

    public static Map operator_plus(Map left, Map right)
    {
        return union(left, right);
    }

    public static Object operator_remove(Map map, Object key)
    {
        return map.remove(key);
    }

    public static boolean operator_remove(Map map, Pair entry)
    {
        Object key = entry.getKey();
        Object storedValue = map.get(entry.getKey());
        if(!Objects.equal(storedValue, entry.getValue()) || storedValue == null && !map.containsKey(key))
        {
            return false;
        } else
        {
            map.remove(key);
            return true;
        }
    }

    public static void operator_remove(Map map, Iterable keysToRemove)
    {
        Object key;
        for(Iterator iterator = keysToRemove.iterator(); iterator.hasNext(); map.remove(key))
            key = iterator.next();

    }

    public static Map operator_minus(Map left, Pair right)
    {
        return Maps.filterEntries(left, new Predicate(right) {

            public boolean apply(java.util.Map.Entry input)
            {
                return !Objects.equal(input.getKey(), right.getKey()) || !Objects.equal(input.getValue(), right.getValue());
            }

            public volatile boolean apply(Object obj)
            {
                return apply((java.util.Map.Entry)obj);
            }

            final Pair val$right;

            
            {
                right = pair;
                super();
            }
        }
);
    }

    public static Map operator_minus(Map map, Object key)
    {
        return Maps.filterKeys(map, new Predicate(key) {

            public boolean apply(Object input)
            {
                return !Objects.equal(input, key);
            }

            final Object val$key;

            
            {
                key = obj;
                super();
            }
        }
);
    }

    public static Map operator_minus(Map left, Map right)
    {
        return Maps.filterEntries(left, new Predicate(right) {

            public boolean apply(java.util.Map.Entry input)
            {
                Object value = right.get(input.getKey());
                if(value == null)
                    return input.getValue() == null && right.containsKey(input.getKey());
                else
                    return !Objects.equal(input.getValue(), value);
            }

            public volatile boolean apply(Object obj)
            {
                return apply((java.util.Map.Entry)obj);
            }

            final Map val$right;

            
            {
                right = map;
                super();
            }
        }
);
    }

    public static Map operator_minus(Map map, Iterable keys)
    {
        return Maps.filterKeys(map, new Predicate(keys) {

            public boolean apply(Object input)
            {
                return !Iterables.contains(keys, input);
            }

            final Iterable val$keys;

            
            {
                keys = iterable;
                super();
            }
        }
);
    }

    public static Map union(Map left, Map right)
    {
        return new UnmodifiableMergingMapView(left, right);
    }

    public static Map mapValues(Map original, Functions.Function1 transformation)
    {
        return Maps.transformValues(original, new FunctionDelegate(transformation));
    }
}
