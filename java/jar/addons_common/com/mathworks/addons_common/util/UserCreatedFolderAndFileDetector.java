// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   UserCreatedFolderAndFileDetector.java

package com.mathworks.addons_common.util;

import com.mathworks.addons_common.installation_folder.InstallationFolderView;
import com.mathworks.addons_common.installation_folder.InstallationFolderViewFactory;
import java.io.IOException;
import java.nio.file.*;
import java.nio.file.attribute.BasicFileAttributes;

final class UserCreatedFolderAndFileDetector extends SimpleFileVisitor
{

    public UserCreatedFolderAndFileDetector(Path path)
    {
        installationFolder = path;
        userCreatedFileOrFolderExists = Boolean.valueOf(false);
    }

    public FileVisitResult visitFile(Path path, BasicFileAttributes basicfileattributes)
    {
        userCreatedFileOrFolderExists = Boolean.valueOf(true);
        return FileVisitResult.TERMINATE;
    }

    public Boolean doesUserCreatedFileOrFolderExists()
    {
        return userCreatedFileOrFolderExists;
    }

    public FileVisitResult preVisitDirectory(Path path, BasicFileAttributes basicfileattributes)
    {
        InstallationFolderView installationfolderview = InstallationFolderViewFactory.getDefaultView(installationFolder);
        if(path.equals(installationFolder) || path.equals(installationfolderview.getMetadataFolder()))
        {
            return FileVisitResult.CONTINUE;
        } else
        {
            userCreatedFileOrFolderExists = Boolean.valueOf(true);
            return FileVisitResult.TERMINATE;
        }
    }

    public volatile FileVisitResult visitFile(Object obj, BasicFileAttributes basicfileattributes)
        throws IOException
    {
        return visitFile((Path)obj, basicfileattributes);
    }

    public volatile FileVisitResult preVisitDirectory(Object obj, BasicFileAttributes basicfileattributes)
        throws IOException
    {
        return preVisitDirectory((Path)obj, basicfileattributes);
    }

    private static Boolean userCreatedFileOrFolderExists;
    private Path installationFolder;
}
