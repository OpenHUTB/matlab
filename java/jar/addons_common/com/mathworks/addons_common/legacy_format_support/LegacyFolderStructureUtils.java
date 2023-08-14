// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   LegacyFolderStructureUtils.java

package com.mathworks.addons_common.legacy_format_support;

import java.nio.file.*;

public final class LegacyFolderStructureUtils
{

    private LegacyFolderStructureUtils()
    {
    }

    public static boolean legacyMetadataFolderExistsIn(Path path)
    {
        return Files.exists(path.resolve(".addOnMetadata"), new LinkOption[0]);
    }

    public static Path retrieveLegacyMetadataFolderIn(Path path)
    {
        return path.resolve(".addOnMetadata");
    }

    public static boolean legacyCodeFolderExistsIn(Path path)
    {
        return Files.exists(path.resolve("code"), new LinkOption[0]);
    }

    public static Path retrieveLegacyCodeFolderIn(Path path)
    {
        return path.resolve("code");
    }

    public static final String LEGACY_METADATA_FOLDER_NAME = ".addOnMetadata";
    public static final String LEGACY_CODE_FOLDER_NAME = "code";
}
