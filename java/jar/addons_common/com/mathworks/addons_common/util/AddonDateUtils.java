// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   AddonDateUtils.java

package com.mathworks.addons_common.util;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

public final class AddonDateUtils
{

    private AddonDateUtils()
    {
    }

    public static Date convertStringToDateUsingUSLocale(String s, String s1)
        throws ParseException
    {
        SimpleDateFormat simpledateformat = new SimpleDateFormat(s1, Locale.US);
        return simpledateformat.parse(s);
    }

    public static long convertDateToMilliseconds(Date date)
    {
        return date.getTime();
    }

    public static final long MILLISECONDS_PER_DAY = 0x5265c00L;
}
