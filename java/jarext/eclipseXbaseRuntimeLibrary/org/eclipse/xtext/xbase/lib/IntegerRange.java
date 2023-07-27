// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   IntegerRange.java

package org.eclipse.xtext.xbase.lib;

import java.util.*;

public class IntegerRange
    implements Iterable
{
    private class RangeIterator
        implements ListIterator
    {

        public boolean hasNext()
        {
            if(step < 0)
                return next >= end;
            else
                return next <= end;
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
        final IntegerRange this$0;

        private RangeIterator()
        {
            this$0 = IntegerRange.this;
            super();
            next = start;
            nextIndex = 0;
        }

    }


    public ListIterator iterator()
    {
        return new RangeIterator();
    }

    public IntegerRange(int start, int end)
    {
        this(start, end, end < start ? -1 : 1);
    }

    public IntegerRange(int start, int end, int step)
    {
        if(start < end && step < 0 || start > end && step > 0)
            throw new IllegalArgumentException("The step of an IntegerRange must have the correct sign.");
        if(step == 0)
        {
            throw new IllegalArgumentException("The step of an IntegerRange must not be 0");
        } else
        {
            this.start = start;
            this.end = end;
            this.step = step;
            return;
        }
    }

    public int getStart()
    {
        return start;
    }

    public int getStep()
    {
        return step;
    }

    public int getEnd()
    {
        return end;
    }

    public int getSize()
    {
        return (end - start) / step + 1;
    }

    public IntegerRange withStep(int step)
    {
        return new IntegerRange(start, end, step);
    }

    public boolean contains(int number)
    {
        if(step < 0)
            return number <= start && number >= end && (number - start) % step == 0;
        else
            return number >= start && number <= end && (number - start) % step == 0;
    }

    public volatile Iterator iterator()
    {
        return iterator();
    }

    private final int start;
    private final int end;
    private final int step;



}
