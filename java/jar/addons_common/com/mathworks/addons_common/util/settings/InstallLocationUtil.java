// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   InstallLocationUtil.java

package com.mathworks.addons_common.util.settings;

import java.nio.file.Path;

final class InstallLocationUtil
{

    InstallLocationUtil()
    {
    }

    static boolean mustCacheBeUpdated(Path path, Path path1, Path path2)
    {
        if(path1 == null || path1.equals(path2))
            return path != null && !path.equals(path2);
        else
            return !path1.equals(path);
    }
}
