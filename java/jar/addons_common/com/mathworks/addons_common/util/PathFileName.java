// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   PathFileName.java

package com.mathworks.addons_common.util;


public final class PathFileName extends Enum
{

    public static PathFileName[] values()
    {
        return (PathFileName[])$VALUES.clone();
    }

    public static PathFileName valueOf(String s)
    {
        return (PathFileName)Enum.valueOf(com/mathworks/addons_common/util/PathFileName, s);
    }

    private PathFileName(String s, int i, String s1)
    {
        super(s, i);
        pathFileName = s1;
    }

    public String toString()
    {
        return pathFileName;
    }

    public static final PathFileName FOR_TOOLBOXES;
    public static final PathFileName FOR_ZIPS;
    private final String pathFileName;
    private static final PathFileName $VALUES[];

    static 
    {
        FOR_TOOLBOXES = new PathFileName("FOR_TOOLBOXES", 0, ".toolboxFolders");
        FOR_ZIPS = new PathFileName("FOR_ZIPS", 1, ".zipFolders");
        $VALUES = (new PathFileName[] {
            FOR_TOOLBOXES, FOR_ZIPS
        });
    }
}
