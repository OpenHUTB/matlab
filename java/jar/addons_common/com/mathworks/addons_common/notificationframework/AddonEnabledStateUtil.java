// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   AddonEnabledStateUtil.java

package com.mathworks.addons_common.notificationframework;

import com.mathworks.addons_common.exceptions.AddOnNotFoundException;

// Referenced classes of package com.mathworks.addons_common.notificationframework:
//            FolderRegistry

public final class AddonEnabledStateUtil
{

    private AddonEnabledStateUtil()
    {
    }

    public static boolean isEnabled(String s, String s1)
        throws AddOnNotFoundException
    {
        return !FolderRegistry.hasEntryWithIdentifierAndVersion(s, s1) || FolderRegistry.isEnabled(s, s1);
    }
}
