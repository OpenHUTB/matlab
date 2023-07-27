// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   ZipFileEntryDecorator.java

package com.mathworks.addons_common.zipfile;

import java.io.*;
import java.util.Date;
import org.apache.commons.compress.archivers.ArchiveEntry;
import org.apache.commons.compress.archivers.zip.ZipArchiveEntry;
import org.apache.commons.compress.archivers.zip.ZipFile;
import org.apache.commons.io.IOUtils;

public final class ZipFileEntryDecorator
    implements ArchiveEntry
{

    public ZipFileEntryDecorator(ZipArchiveEntry ziparchiveentry, ZipFile zipfile)
    {
        zipFileThatContainsTheEntry = zipfile;
        zipArchiveEntry = ziparchiveentry;
    }

    public void extractInto(File file)
        throws IOException
    {
        File file1;
        InputStream inputstream;
        Throwable throwable;
        file1 = new File(file, zipArchiveEntry.getName());
        createParentFoldersOf(file1);
        if(zipArchiveEntry.isDirectory())
        {
            file1.mkdirs();
            break MISSING_BLOCK_LABEL_242;
        }
        inputstream = zipFileThatContainsTheEntry.getInputStream(zipArchiveEntry);
        throwable = null;
        FileOutputStream fileoutputstream;
        Throwable throwable3;
        fileoutputstream = new FileOutputStream(file1);
        throwable3 = null;
        try
        {
            IOUtils.copy(inputstream, fileoutputstream);
        }
        catch(Throwable throwable5)
        {
            throwable3 = throwable5;
            throw throwable5;
        }
        if(fileoutputstream != null)
            if(throwable3 != null)
                try
                {
                    fileoutputstream.close();
                }
                catch(Throwable throwable4)
                {
                    throwable3.addSuppressed(throwable4);
                }
            else
                fileoutputstream.close();
        break MISSING_BLOCK_LABEL_161;
        Exception exception;
        exception;
        if(fileoutputstream != null)
            if(throwable3 != null)
                try
                {
                    fileoutputstream.close();
                }
                catch(Throwable throwable6)
                {
                    throwable3.addSuppressed(throwable6);
                }
            else
                fileoutputstream.close();
        throw exception;
        if(inputstream != null)
            if(throwable != null)
                try
                {
                    inputstream.close();
                }
                catch(Throwable throwable1)
                {
                    throwable.addSuppressed(throwable1);
                }
            else
                inputstream.close();
        break MISSING_BLOCK_LABEL_242;
        Throwable throwable2;
        throwable2;
        throwable = throwable2;
        throw throwable2;
        Exception exception1;
        exception1;
        if(inputstream != null)
            if(throwable != null)
                try
                {
                    inputstream.close();
                }
                catch(Throwable throwable7)
                {
                    throwable.addSuppressed(throwable7);
                }
            else
                inputstream.close();
        throw exception1;
    }

    private void createParentFoldersOf(File file)
    {
        file.getParentFile().mkdirs();
    }

    public String getName()
    {
        return zipArchiveEntry.getName();
    }

    public long getSize()
    {
        return zipArchiveEntry.getSize();
    }

    public boolean isDirectory()
    {
        return zipArchiveEntry.isDirectory();
    }

    public Date getLastModifiedDate()
    {
        return zipArchiveEntry.getLastModifiedDate();
    }

    private final ZipFile zipFileThatContainsTheEntry;
    private final ZipArchiveEntry zipArchiveEntry;
}
