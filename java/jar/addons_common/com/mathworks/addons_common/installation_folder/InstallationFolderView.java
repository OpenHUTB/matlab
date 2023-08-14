// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   InstallationFolderView.java

package com.mathworks.addons_common.installation_folder;

import java.nio.file.Path;

public abstract class InstallationFolderView
{

    public InstallationFolderView(Path path)
    {
        fRoot = path;
    }

    public Path getRootFolder()
    {
        return fRoot;
    }

    public abstract Path getCodeFolder();

    public abstract Path getMetadataFolder();

    private Path fRoot;
}
