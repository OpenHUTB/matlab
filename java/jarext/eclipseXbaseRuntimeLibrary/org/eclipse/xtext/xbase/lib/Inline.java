// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   Inline.java

package org.eclipse.xtext.xbase.lib;

import java.lang.annotation.Annotation;

public interface Inline
    extends Annotation
{

    public abstract String value();

    public abstract Class[] imported();

    public abstract boolean statementExpression();

    public abstract boolean constantExpression();
}
