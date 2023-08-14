// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   GalleryUrlPref.java

package com.mathworks.addons_common.util.settings;

import com.mathworks.mlwebservices.WSEndPoints;
import com.mathworks.mvm.MVM;
import com.mathworks.mvm.context.MvmContext;
import com.mathworks.services.settings.*;
import com.mathworks.webservices.urlmanager.UrlManager;

/**
 * @deprecated Class GalleryUrlPref is deprecated
 */

public final class GalleryUrlPref
{

    private GalleryUrlPref()
    {
    }

    /**
     * @deprecated Method get is deprecated
     */

    public static String get()
    {
        MVM mvm = MvmContext.get();
        try
        {
            SettingPath settingpath = new SettingPath(mvm, new String[] {
                "matlab", "addons", "explorer"
            });
            Setting setting = new Setting(settingpath, java/lang/String, "preferredEndPoint");
            return (String)setting.get();
        }
        catch(Object obj)
        {
            return DEFAULT_GALLERY_URL;
        }
    }

    /**
     * @deprecated Method set is deprecated
     */

    public static void set(String s)
    {
        MVM mvm = MvmContext.get();
        mvm.eval((new StringBuilder()).append("matlab.internal.addons.util.explorer.baseUrl.set('").append(s).append("')").toString());
    }

    /**
     * @deprecated Method remove is deprecated
     */

    public static void remove()
    {
        MVM mvm = MvmContext.get();
        try
        {
            SettingPath settingpath = new SettingPath(mvm, new String[] {
                "matlab", "addons", "explorer"
            });
            settingpath.delete("preferredEndPoint");
        }
        catch(Object obj) { }
        return;
    }

    private static final String DEFAULT_GALLERY_URL;
    private static final String KEY = "Addons_Gallery_Url";

    static 
    {
        DEFAULT_GALLERY_URL = WSEndPoints.getEndPointByKey(UrlManager.ADD_ONS);
    }
}
