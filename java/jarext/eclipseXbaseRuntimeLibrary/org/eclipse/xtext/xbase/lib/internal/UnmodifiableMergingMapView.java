// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   UnmodifiableMergingMapView.java

package org.eclipse.xtext.xbase.lib.internal;

import com.google.common.base.Predicate;
import com.google.common.collect.Iterators;
import java.util.*;
import java.util.function.BiFunction;

public class UnmodifiableMergingMapView extends AbstractMap
{
    private static abstract class AbstractEarlyFailingSet extends AbstractSet
    {

        public void clear()
        {
            throw new UnsupportedOperationException();
        }

        public boolean add(Object entry)
        {
            throw new UnsupportedOperationException();
        }

        public boolean remove(Object element)
        {
            throw new UnsupportedOperationException();
        }

        AbstractEarlyFailingSet()
        {
        }
    }


    public UnmodifiableMergingMapView(Map left, Map right)
    {
        if(!$assertionsDisabled && left == null)
            throw new AssertionError("left must not be null");
        if(!$assertionsDisabled && right == null)
        {
            throw new AssertionError("right must not be null");
        } else
        {
            this.left = left;
            this.right = right;
            return;
        }
    }

    public Set entrySet()
    {
        final Set diff = difference(left, right);
        return new AbstractEarlyFailingSet() {

            public Iterator iterator()
            {
                return Iterators.unmodifiableIterator(Iterators.concat(right.entrySet().iterator(), diff.iterator()));
            }

            public int size()
            {
                return Iterators.size(iterator());
            }

            final Set val$diff;
            final UnmodifiableMergingMapView this$0;

            
            {
                this.this$0 = UnmodifiableMergingMapView.this;
                diff = set;
                super();
            }
        }
;
    }

    private static Set difference(Map left, Map right)
    {
        Predicate notInSet = new Predicate(right) {

            public boolean apply(java.util.Map.Entry it)
            {
                if(it == null)
                    return false;
                else
                    return !right.containsKey(it.getKey());
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
;
        return new AbstractEarlyFailingSet(left, notInSet) {

            public Iterator iterator()
            {
                return Iterators.unmodifiableIterator(Iterators.filter(left.entrySet().iterator(), notInSet));
            }

            public int size()
            {
                return Iterators.size(iterator());
            }

            final Map val$left;
            final Predicate val$notInSet;

            
            {
                left = map;
                notInSet = predicate;
                super();
            }
        }
;
    }

    public void clear()
    {
        throw new UnsupportedOperationException();
    }

    public Object put(Object key, Object value)
    {
        throw new UnsupportedOperationException();
    }

    public Object remove(Object key)
    {
        throw new UnsupportedOperationException();
    }

    public void replaceAll(BiFunction function)
    {
        throw new UnsupportedOperationException();
    }

    private final Map left;
    private final Map right;
    static final boolean $assertionsDisabled = !org/eclipse/xtext/xbase/lib/internal/UnmodifiableMergingMapView.desiredAssertionStatus();


}
