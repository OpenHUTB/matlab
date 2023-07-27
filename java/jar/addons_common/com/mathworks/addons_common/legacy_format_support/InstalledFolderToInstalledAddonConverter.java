// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   InstalledFolderToInstalledAddonConverter.java

package com.mathworks.addons_common.legacy_format_support;

import com.mathworks.addons_common.InstalledAddon;
import java.nio.file.Path;

public interface InstalledFolderToInstalledAddonConverter
{

    public abstract boolean isValidMetadataFile(Path path);

    public abstract InstalledAddon generateInstalledAddon(Path path, Path path1)
        throws Exception;
}
