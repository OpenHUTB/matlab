// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   MetadataFileUtils.java

package com.mathworks.addons_common.util;

import com.mathworks.addons_registry.MetadataFileUtils_Jni;
import java.net.URL;
import java.nio.file.Path;

public final class MetadataFileUtils
{

    private MetadataFileUtils()
    {
    }

    public static String getIdentifier(Path path)
    {
        return MetadataFileUtils_Jni.getIdentifier(path);
    }

    public static String getDisplayType(Path path)
    {
        return MetadataFileUtils_Jni.getDisplayType(path);
    }

    public static String getVersion(Path path)
    {
        return MetadataFileUtils_Jni.getVersion(path);
    }

    public static String getName(Path path)
    {
        return MetadataFileUtils_Jni.getName(path);
    }

    public static String getDownloadUrl(Path path)
    {
        return MetadataFileUtils_Jni.getDownloadUrl(path);
    }

    public static String getAuthor(Path path)
    {
        return MetadataFileUtils_Jni.getAuthor(path);
    }

    public static String getPreviewImageUrl(Path path)
    {
        return MetadataFileUtils_Jni.getPreviewImageUrl(path);
    }

    public static String getPreviewImageUrl(URL url)
    {
        return MetadataFileUtils_Jni.getPreviewImageUrl(url);
    }

    public static String getInstallationFolder(Path path)
    {
        return MetadataFileUtils_Jni.getInstallationFolder(path);
    }

    public static String getLicenseAgreementUrl(Path path)
    {
        return MetadataFileUtils_Jni.getLicenseAgreementUrl(path);
    }

    public static String getMetadataUrlAsStringForAddOn(String s, String s1)
    {
        return MetadataFileUtils_Jni.getMetadataUrlAsStringForAddOn(s, s1);
    }
}
