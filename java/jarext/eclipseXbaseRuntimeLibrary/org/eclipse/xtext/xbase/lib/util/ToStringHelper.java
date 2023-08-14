// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   ToStringHelper.java

package org.eclipse.xtext.xbase.lib.util;


// Referenced classes of package org.eclipse.xtext.xbase.lib.util:
//            ToStringBuilder

/**
 * @deprecated Class ToStringHelper is deprecated
 */

public class ToStringHelper
{

    /**
     * @deprecated Method ToStringHelper is deprecated
     */

    public ToStringHelper()
    {
    }

    /**
     * @deprecated Method toString is deprecated
     */

    public String toString(Object obj)
    {
        return (new ToStringBuilder(obj)).addAllFields().toString();
    }
}
