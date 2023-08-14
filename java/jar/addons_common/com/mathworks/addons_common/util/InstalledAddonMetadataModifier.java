// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   InstalledAddonMetadataModifier.java

package com.mathworks.addons_common.util;

import com.mathworks.addons_common.InstalledAddon;
import com.mathworks.addons_metadata.AddonMetadataProvider;

public interface InstalledAddonMetadataModifier
{

    public abstract void ModifyInstalledAddonBuilderFromMetadata(String s, com.mathworks.addons_common.InstalledAddon.Builder builder, AddonMetadataProvider addonmetadataprovider);
}
