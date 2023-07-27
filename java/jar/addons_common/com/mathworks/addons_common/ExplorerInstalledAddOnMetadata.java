// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   ExplorerInstalledAddOnMetadata.java

package com.mathworks.addons_common;

import com.mathworks.addons_common.util.AddonDateUtils;
import java.util.Date;

public final class ExplorerInstalledAddOnMetadata
{

    public ExplorerInstalledAddOnMetadata(String s, String s1, String s2, Date date, int i, boolean flag, boolean flag1)
    {
        addOnType = s;
        identifier = s1;
        version = s2;
        trialDaysRemaining = i;
        trial = flag;
        if(date != null)
            installedDate = AddonDateUtils.convertDateToMilliseconds(date);
        hasDocumentation = flag1;
    }

    public boolean hasDocumentation()
    {
        return hasDocumentation;
    }

    private String addOnType;
    private String identifier;
    private String version;
    private long installedDate;
    private int trialDaysRemaining;
    private boolean trial;
    private boolean hasDocumentation;
}
