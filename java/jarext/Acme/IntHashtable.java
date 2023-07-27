// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   IntHashtable.java

package Acme;

import java.util.Dictionary;
import java.util.Enumeration;

// Referenced classes of package Acme:
//            IntHashtableEnumerator, IntHashtableEntry

public class IntHashtable extends Dictionary
    implements Cloneable
{

    public int size()
    {
        return count;
    }

    public boolean isEmpty()
    {
        return count == 0;
    }

    public synchronized Enumeration keys()
    {
        return new IntHashtableEnumerator(table, true);
    }

    public synchronized Enumeration elements()
    {
        return new IntHashtableEnumerator(table, false);
    }

    public synchronized boolean contains(Object obj)
    {
        if(obj == null)
            throw new NullPointerException();
        IntHashtableEntry ainthashtableentry[] = table;
        for(int i = ainthashtableentry.length; i-- > 0;)
        {
            for(IntHashtableEntry inthashtableentry = ainthashtableentry[i]; inthashtableentry != null; inthashtableentry = inthashtableentry.next)
                if(inthashtableentry.value.equals(obj))
                    return true;

        }

        return false;
    }

    public synchronized boolean containsKey(int i)
    {
        IntHashtableEntry ainthashtableentry[] = table;
        int j = i;
        int k = (j & 0x7fffffff) % ainthashtableentry.length;
        for(IntHashtableEntry inthashtableentry = ainthashtableentry[k]; inthashtableentry != null; inthashtableentry = inthashtableentry.next)
            if(inthashtableentry.hash == j && inthashtableentry.key == i)
                return true;

        return false;
    }

    public synchronized Object get(int i)
    {
        IntHashtableEntry ainthashtableentry[] = table;
        int j = i;
        int k = (j & 0x7fffffff) % ainthashtableentry.length;
        for(IntHashtableEntry inthashtableentry = ainthashtableentry[k]; inthashtableentry != null; inthashtableentry = inthashtableentry.next)
            if(inthashtableentry.hash == j && inthashtableentry.key == i)
                return inthashtableentry.value;

        return null;
    }

    public Object get(Object obj)
    {
        if(!(obj instanceof Integer))
        {
            throw new InternalError("key is not an Integer");
        } else
        {
            Integer integer = (Integer)obj;
            int i = integer.intValue();
            return get(i);
        }
    }

    protected void rehash()
    {
        int i = table.length;
        IntHashtableEntry ainthashtableentry[] = table;
        int j = i * 2 + 1;
        IntHashtableEntry ainthashtableentry1[] = new IntHashtableEntry[j];
        threshold = (int)((float)j * loadFactor);
        table = ainthashtableentry1;
        for(int k = i; k-- > 0;)
        {
            for(IntHashtableEntry inthashtableentry = ainthashtableentry[k]; inthashtableentry != null;)
            {
                IntHashtableEntry inthashtableentry1 = inthashtableentry;
                inthashtableentry = inthashtableentry.next;
                int l = (inthashtableentry1.hash & 0x7fffffff) % j;
                inthashtableentry1.next = ainthashtableentry1[l];
                ainthashtableentry1[l] = inthashtableentry1;
            }

        }

    }

    public synchronized Object put(int i, Object obj)
    {
        if(obj == null)
            throw new NullPointerException();
        IntHashtableEntry ainthashtableentry[] = table;
        int j = i;
        int k = (j & 0x7fffffff) % ainthashtableentry.length;
        for(IntHashtableEntry inthashtableentry = ainthashtableentry[k]; inthashtableentry != null; inthashtableentry = inthashtableentry.next)
            if(inthashtableentry.hash == j && inthashtableentry.key == i)
            {
                Object obj1 = inthashtableentry.value;
                inthashtableentry.value = obj;
                return obj1;
            }

        if(count >= threshold)
        {
            rehash();
            return put(i, obj);
        } else
        {
            IntHashtableEntry inthashtableentry1 = new IntHashtableEntry();
            inthashtableentry1.hash = j;
            inthashtableentry1.key = i;
            inthashtableentry1.value = obj;
            inthashtableentry1.next = ainthashtableentry[k];
            ainthashtableentry[k] = inthashtableentry1;
            count++;
            return null;
        }
    }

    public Object put(Object obj, Object obj1)
    {
        if(!(obj instanceof Integer))
        {
            throw new InternalError("key is not an Integer");
        } else
        {
            Integer integer = (Integer)obj;
            int i = integer.intValue();
            return put(i, obj1);
        }
    }

    public synchronized Object remove(int i)
    {
        IntHashtableEntry ainthashtableentry[] = table;
        int j = i;
        int k = (j & 0x7fffffff) % ainthashtableentry.length;
        IntHashtableEntry inthashtableentry = ainthashtableentry[k];
        IntHashtableEntry inthashtableentry1 = null;
        for(; inthashtableentry != null; inthashtableentry = inthashtableentry.next)
        {
            if(inthashtableentry.hash == j && inthashtableentry.key == i)
            {
                if(inthashtableentry1 != null)
                    inthashtableentry1.next = inthashtableentry.next;
                else
                    ainthashtableentry[k] = inthashtableentry.next;
                count--;
                return inthashtableentry.value;
            }
            inthashtableentry1 = inthashtableentry;
        }

        return null;
    }

    public Object remove(Object obj)
    {
        if(!(obj instanceof Integer))
        {
            throw new InternalError("key is not an Integer");
        } else
        {
            Integer integer = (Integer)obj;
            int i = integer.intValue();
            return remove(i);
        }
    }

    public synchronized void clear()
    {
        IntHashtableEntry ainthashtableentry[] = table;
        for(int i = ainthashtableentry.length; --i >= 0;)
            ainthashtableentry[i] = null;

        count = 0;
    }

    public synchronized Object clone()
    {
        try
        {
            IntHashtable inthashtable = (IntHashtable)super.clone();
            inthashtable.table = new IntHashtableEntry[table.length];
            for(int i = table.length; i-- > 0;)
                inthashtable.table[i] = table[i] == null ? null : (IntHashtableEntry)table[i].clone();

            return inthashtable;
        }
        catch(CloneNotSupportedException clonenotsupportedexception)
        {
            throw new InternalError();
        }
    }

    public synchronized String toString()
    {
        int i = size() - 1;
        StringBuffer stringbuffer = new StringBuffer();
        Enumeration enumeration = keys();
        Enumeration enumeration1 = elements();
        stringbuffer.append("{");
        for(int j = 0; j <= i; j++)
        {
            String s = enumeration.nextElement().toString();
            String s1 = enumeration1.nextElement().toString();
            stringbuffer.append(s + "=" + s1);
            if(j < i)
                stringbuffer.append(", ");
        }

        stringbuffer.append("}");
        return stringbuffer.toString();
    }

    public IntHashtable(int i, float f)
    {
        if(i <= 0 || (double)f <= 0.0D)
        {
            throw new IllegalArgumentException();
        } else
        {
            loadFactor = f;
            table = new IntHashtableEntry[i];
            threshold = (int)((float)i * f);
            return;
        }
    }

    public IntHashtable(int i)
    {
        this(i, 0.75F);
    }

    public IntHashtable()
    {
        this(101, 0.75F);
    }

    private IntHashtableEntry table[];
    private int count;
    private int threshold;
    private float loadFactor;
}
