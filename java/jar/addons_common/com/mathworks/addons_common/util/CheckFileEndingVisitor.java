// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   CheckFileEndingVisitor.java

package com.mathworks.addons_common.util;

import java.io.IOException;
import java.nio.file.*;
import java.nio.file.attribute.BasicFileAttributes;
import org.apache.commons.io.FilenameUtils;

public class CheckFileEndingVisitor extends SimpleFileVisitor
{

    public CheckFileEndingVisitor(String s)
    {
        if(s.startsWith("."))
        {
            throw new IllegalArgumentException("Pass in fileExtension without the '.'");
        } else
        {
            fFileExtension = s;
            fOnlyFileExtension = false;
            return;
        }
    }

    public FileVisitResult visitFile(Path path, BasicFileAttributes basicfileattributes)
    {
        String s = path.toString().toLowerCase();
        if(FilenameUtils.isExtension(s, fFileExtension))
        {
            return FileVisitResult.CONTINUE;
        } else
        {
            fOnlyFileExtension = false;
            return FileVisitResult.TERMINATE;
        }
    }

    public FileVisitResult postVisitDirectory(Path path, IOException ioexception)
    {
        return FileVisitResult.CONTINUE;
    }

    public FileVisitResult visitFileFailed(Path path, IOException ioexception)
    {
        return FileVisitResult.CONTINUE;
    }

    public boolean onlyContainsFileEnding()
    {
        return fOnlyFileExtension;
    }

    public volatile FileVisitResult postVisitDirectory(Object obj, IOException ioexception)
        throws IOException
    {
        return postVisitDirectory((Path)obj, ioexception);
    }

    public volatile FileVisitResult visitFileFailed(Object obj, IOException ioexception)
        throws IOException
    {
        return visitFileFailed((Path)obj, ioexception);
    }

    public volatile FileVisitResult visitFile(Object obj, BasicFileAttributes basicfileattributes)
        throws IOException
    {
        return visitFile((Path)obj, basicfileattributes);
    }

    private final String fFileExtension;
    private boolean fOnlyFileExtension;
}
