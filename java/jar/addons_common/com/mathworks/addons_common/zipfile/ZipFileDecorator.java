// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   ZipFileDecorator.java

package com.mathworks.addons_common.zipfile;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.util.Enumeration;
import org.apache.commons.compress.archivers.zip.ZipArchiveEntry;
import org.apache.commons.compress.archivers.zip.ZipFile;
import org.apache.commons.io.IOUtils;

// Referenced classes of package com.mathworks.addons_common.zipfile:
//            ZipFileEntryDecorator

public final class ZipFileDecorator
    implements AutoCloseable
{

    public ZipFileDecorator(File file)
        throws IOException
    {
        zipFile = new ZipFile(file);
    }

    public void extractInto(File file)
        throws IOException
    {
        ZipFileEntryDecorator zipfileentrydecorator;
        for(Enumeration enumeration = zipFile.getEntries(); enumeration.hasMoreElements(); zipfileentrydecorator.extractInto(file))
        {
            ZipArchiveEntry ziparchiveentry = (ZipArchiveEntry)enumeration.nextElement();
            zipfileentrydecorator = new ZipFileEntryDecorator(ziparchiveentry, zipFile);
        }

    }

    public boolean contains(String s)
    {
        ZipArchiveEntry ziparchiveentry = zipFile.getEntry(s);
        return ziparchiveentry != null;
    }

    public String readStringFromFile(String s)
        throws IOException
    {
        InputStream inputstream;
        Throwable throwable;
        ZipArchiveEntry ziparchiveentry = zipFile.getEntry(s);
        if(!contains(s))
            throw new IOException((new StringBuilder()).append("The ZIP file does not contain '").append(s).append("'.").toString());
        inputstream = zipFile.getInputStream(ziparchiveentry);
        throwable = null;
        String s1;
        try
        {
            s1 = IOUtils.toString(inputstream, StandardCharsets.UTF_8);
        }
        catch(Throwable throwable1)
        {
            throwable = throwable1;
            throw throwable1;
        }
        if(inputstream != null)
            if(throwable != null)
                try
                {
                    inputstream.close();
                }
                catch(Throwable throwable2)
                {
                    throwable.addSuppressed(throwable2);
                }
            else
                inputstream.close();
        return s1;
        Exception exception;
        exception;
        if(inputstream != null)
            if(throwable != null)
                try
                {
                    inputstream.close();
                }
                catch(Throwable throwable3)
                {
                    throwable.addSuppressed(throwable3);
                }
            else
                inputstream.close();
        throw exception;
    }

    public void close()
        throws Exception
    {
        zipFile.close();
    }

    private final ZipFile zipFile;
}
