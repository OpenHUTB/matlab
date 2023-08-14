// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   ExclusiveRange.java

package org.eclipse.xtext.xbase.lib;

import java.util.*;

public class ExclusiveRange
    implements Iterable
{
    private class RangeIterator
        implements ListIterator
    {

        public boolean hasNext()
        {
            if(step < 0)
                return next >= last;
            else
                return next <= last;
        }

        public Integer next()
        {
            if(!hasNext())
            {
                throw new NoSuchElementException();
            } else
            {
                int value = next;
                next += step;
                nextIndex++;
                return Integer.valueOf(value);
            }
        }

        public boolean hasPrevious()
        {
            return nextIndex > 0;
        }

        public Integer previous()
        {
            if(nextIndex <= 0)
            {
                throw new NoSuchElementException();
            } else
            {
                nextIndex--;
                next -= step;
                return Integer.valueOf(next);
            }
        }

        public int nextIndex()
        {
            return nextIndex;
        }

        public int previousIndex()
        {
            return nextIndex - 1;
        }

        public void remove()
        {
            throw new UnsupportedOperationException("Cannot remove elements from a Range");
        }

        public void set(Integer e)
        {
            throw new UnsupportedOperationException("Cannot set elements in a Range");
        }

        public void add(Integer e)
        {
            throw new UnsupportedOperationException("Cannot add elements to a Range");
        }

        public volatile void add(Object obj)
        {
            add((Integer)obj);
        }

        public volatile void set(Object obj)
        {
            set((Integer)obj);
        }

        public volatile Object previous()
        {
            return previous();
        }

        public volatile Object next()
        {
            return next();
        }

        private int next;
        private int nextIndex;
        final ExclusiveRange this$0;

        private RangeIterator()
        {
            this$0 = ExclusiveRange.this;
            super();
            next = first;
            nextIndex = 0;
        }

    }


    public ListIterator iterator()
    {
        return ((ListIterator) (isEmpty() ? EMPTY_LIST_ITERATOR : new RangeIterator()));
    }

    public ExclusiveRange(int start, int end, boolean increment)
    {
        if(increment)
        {
            first = start;
            last = end - 1;
            step = 1;
        } else
        {
            first = start - 1;
            last = end;
            step = -1;
        }
    }

    public int size()
    {
        return isEmpty() ? 0 : Math.abs(last - first) + 1;
    }

    public boolean isEmpty()
    {
        return (last - first) * step < 0;
    }

    public boolean contains(int number)
    {
        if(isEmpty())
            return false;
        if(step == -1)
            return number <= first && number >= last;
        else
            return number >= first && number <= last;
    }

    public volatile Iterator iterator()
    {
        return iterator();
    }

    private final int first;
    private final int last;
    private final int step;
    private static final ListIterator EMPTY_LIST_ITERATOR = new ListIterator() {

        public boolean hasNext()
        {
            return false;
        }

        public Integer next()
        {
            throw new NoSuchElementException();
        }

        public boolean hasPrevious()
        {
            return false;
        }

        public Integer previous()
        {
            throw new NoSuchElementException();
        }

        public int nextIndex()
        {
            return -1;
        }

        public int previousIndex()
        {
            return -1;
        }

        public void remove()
        {
            throw new UnsupportedOperationException("Cannot remove elements from a Range");
        }

        public void set(Integer e)
        {
            throw new UnsupportedOperationException("Cannot set elements in a Range");
        }

        public void add(Integer e)
        {
            throw new UnsupportedOperationException("Cannot add elements to a Range");
        }

        public volatile void add(Object obj)
        {
            add((Integer)obj);
        }

        public volatile void set(Object obj)
        {
            set((Integer)obj);
        }

        public volatile Object previous()
        {
            return previous();
        }

        public volatile Object next()
        {
            return next();
        }

    }
;




}
