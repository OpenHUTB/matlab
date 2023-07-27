// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   Procedures.java

package org.eclipse.xtext.xbase.lib;


public interface Procedures
{
    public static interface Procedure6
    {

        public abstract void apply(Object obj, Object obj1, Object obj2, Object obj3, Object obj4, Object obj5);
    }

    public static interface Procedure5
    {

        public abstract void apply(Object obj, Object obj1, Object obj2, Object obj3, Object obj4);
    }

    public static interface Procedure4
    {

        public abstract void apply(Object obj, Object obj1, Object obj2, Object obj3);
    }

    public static interface Procedure3
    {

        public abstract void apply(Object obj, Object obj1, Object obj2);
    }

    public static interface Procedure2
    {

        public abstract void apply(Object obj, Object obj1);
    }

    public static interface Procedure1
    {

        public abstract void apply(Object obj);
    }

    public static interface Procedure0
    {

        public abstract void apply();
    }

}
