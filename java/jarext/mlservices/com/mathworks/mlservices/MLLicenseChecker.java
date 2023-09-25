// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   MLLicenseChecker.java

package com.mathworks.mlservices;

import com.mathworks.services.lmgr.NativeLmgr;

public class MLLicenseChecker
{

    public MLLicenseChecker()
    {
    }

    public static boolean[] haveLicenses(String as[])
    {
        boolean aflag[] = new boolean[as.length];
        for(int i = 0; i < as.length; i++)
            aflag[i] = NativeLmgr.testForFeature(as[i]);

        return aflag;
    }

    public static boolean hasLicense(String s)
    {
        String as[] = {
            s
        };
        boolean aflag[] = haveLicenses(as);
        return aflag[0];
    }
}
