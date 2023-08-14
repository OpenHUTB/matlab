// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   AddOnsSettingsUtils.java

package com.mathworks.addons_common.util.settings;

import com.mathworks.mvm.context.MvmContext;
import com.mathworks.services.settings.*;

public final class AddOnsSettingsUtils
{

    private AddOnsSettingsUtils()
    {
    }

    public static Setting getSetting(Class class1, String s)
        throws SettingNotFoundException, SettingTypeException
    {
        com.mathworks.mvm.MVM mvm = MvmContext.get();
        SettingPath settingpath = new SettingPath(mvm, new String[] {
            "matlab", "addons"
        });
        return new Setting(settingpath, class1, s);
    }
}
