// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   Functions.java

package org.eclipse.xtext.xbase.lib;


public interface Functions
{
    public static interface Function6
    {

        public abstract Object apply(Object obj, Object obj1, Object obj2, Object obj3, Object obj4, Object obj5);
    }

    public static interface Function5
    {

        public abstract Object apply(Object obj, Object obj1, Object obj2, Object obj3, Object obj4);
    }

    public static interface Function4
    {

        public abstract Object apply(Object obj, Object obj1, Object obj2, Object obj3);
    }

    public static interface Function3
    {

        public abstract Object apply(Object obj, Object obj1, Object obj2);
    }

    public static interface Function2
    {

        public abstract Object apply(Object obj, Object obj1);
    }

    public static interface Function1
    {

        public abstract Object apply(Object obj);
    }

    public static interface Function0
    {

        public abstract Object apply();
    }

}
