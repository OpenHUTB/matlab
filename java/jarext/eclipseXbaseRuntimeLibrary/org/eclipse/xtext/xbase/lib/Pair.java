// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   Pair.java

package org.eclipse.xtext.xbase.lib;

import com.google.common.base.Objects;
import java.io.Serializable;

public final class Pair
    implements Serializable
{

    public static Pair of(Object k, Object v)
    {
        return new Pair(k, v);
    }

    public Pair(Object k, Object v)
    {
        this.k = k;
        this.v = v;
    }

    public Object getKey()
    {
        return k;
    }

    public Object getValue()
    {
        return v;
    }

    public boolean equals(Object o)
    {
        if(o == this)
            return true;
        if(!(o instanceof Pair))
        {
            return false;
        } else
        {
            Pair e = (Pair)o;
            return Objects.equal(k, e.getKey()) && Objects.equal(v, e.getValue());
        }
    }

    public int hashCode()
    {
        return (k != null ? k.hashCode() : 0) ^ (v != null ? v.hashCode() : 0);
    }

    public String toString()
    {
        return (new StringBuilder()).append(k).append("->").append(v).toString();
    }

    private static final long serialVersionUID = 0xa38bf53eccfc3d3L;
    private final Object k;
    private final Object v;
}
