// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   StringConcatenationClient.java

package org.eclipse.xtend2.lib;


public abstract class StringConcatenationClient
{
    public static interface TargetStringConcatenation
        extends CharSequence
    {

        public abstract void newLineIfNotEmpty();

        public abstract void newLine();

        public abstract void appendImmediate(Object obj, String s);

        public abstract void append(Object obj, String s);

        public abstract void append(Object obj);
    }


    public StringConcatenationClient()
    {
    }

    protected void appendTo(TargetStringConcatenation target)
    {
        throw new UnsupportedOperationException("Clients have to override this.");
    }

    public static void appendTo(StringConcatenationClient client, TargetStringConcatenation target)
    {
        client.appendTo(target);
    }
}
