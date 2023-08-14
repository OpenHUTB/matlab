// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   AddonMetadataResolver.java

package com.mathworks.addons_common.util;

import java.nio.file.Path;

public interface AddonMetadataResolver
{

    public abstract String getAddonTypeServiced();

    public abstract String deriveDisplayType(Path path);
}
