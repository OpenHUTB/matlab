// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   UserEnvironmentInfoUtils.java

package com.mathworks.addons_common.util;

import com.mathworks.instutil.InstutilResourceKeys;
import com.mathworks.util.PlatformInfo;

public final class UserEnvironmentInfoUtils
{

    private UserEnvironmentInfoUtils()
    {
    }

    public static String getPlatformInfo()
    {
        if(PlatformInfo.isWindows64())
            return "Win64";
        if(PlatformInfo.isWindows())
            return "Win32";
        if(PlatformInfo.isIntelMac64())
            return "Mac64";
        if(PlatformInfo.isLinux64())
            return "Lnx64";
        else
            throw new UnsupportedOperationException("We expect the user's platform to be Windows 32- or 64-bit, Mac 64-bit, or Linux 64-bit, but it appears to be none of those.");
    }

    public static String getMatlabRelease()
    {
        return InstutilResourceKeys.RELEASE.getBundleString();
    }

    public static final String PLATFORM_ML_ONLINE = "ml_online";
}
