// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   MatlabPlatformUtil.java

package com.mathworks.addons_common.util;

import com.mathworks.matlab.environment.context.Util;

public final class MatlabPlatformUtil
{

    private MatlabPlatformUtil()
    {
    }

    public static boolean isMatlabOnline()
    {
        return Util.isMATLABOnline();
    }
}
