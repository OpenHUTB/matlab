// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   VersionComparator.java

package com.mathworks.addons_common.util;


public final class VersionComparator
{

    public VersionComparator()
    {
    }

    public static int compare(String s, String s1)
    {
        if(s.equals(s1))
            return 0;
        String as[] = s.split("\\.");
        String as1[] = s1.split("\\.");
        for(int i = 0; i < as.length; i++)
        {
            if(i == as1.length)
                return -1;
            int j = Integer.parseInt(as[i]);
            int k = Integer.parseInt(as1[i]);
            if(j > k)
                return -1;
            if(j < k)
                return 1;
        }

        return as1.length <= as.length ? 0 : 1;
    }
}
