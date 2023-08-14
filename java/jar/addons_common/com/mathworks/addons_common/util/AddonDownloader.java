// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   AddonDownloader.java

package com.mathworks.addons_common.util;

import java.io.File;
import java.io.IOException;
import java.net.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.attribute.FileAttribute;
import org.apache.commons.io.FileUtils;
import org.apache.commons.io.FilenameUtils;

// Referenced classes of package com.mathworks.addons_common.util:
//            URLConnectionFactory

public final class AddonDownloader
{

    private AddonDownloader()
    {
    }

    public static File downloadToTempDir(URL url)
        throws IOException
    {
        int i = 0;
        URL url1 = url;
        boolean flag;
        URLConnection urlconnection;
        do
        {
            urlconnection = getConnection(url1);
            if(urlconnection instanceof HttpURLConnection)
            {
                HttpURLConnection httpurlconnection = (HttpURLConnection)urlconnection;
                int j = httpurlconnection.getResponseCode();
                if(j != 200)
                {
                    flag = true;
                    if(++i == 10)
                        throw new IOException();
                    url1 = getRedirectedLocation(httpurlconnection);
                } else
                {
                    flag = false;
                }
            } else
            {
                flag = false;
            }
        } while(flag);
        return downloadFile(urlconnection);
    }

    static File downloadFile(URLConnection urlconnection)
        throws IOException
    {
        String s = urlconnection.getHeaderField("Content-Disposition");
        File file;
        if(s != null)
        {
            String s1 = s.replaceFirst("(?i)^.*filename=\"?([^\"]+)\"?.*$", "$1");
            file = deriveTempFileLocation(s1);
        } else
        {
            file = deriveTempFileLocation(urlconnection.getURL());
        }
        FileUtils.copyInputStreamToFile(urlconnection.getInputStream(), file);
        return file;
    }

    static URLConnection getConnection(URL url)
        throws IOException
    {
        URLConnection urlconnection = URLConnectionFactory.getUrlConnection(url);
        if(urlconnection instanceof HttpURLConnection)
        {
            HttpURLConnection httpurlconnection = (HttpURLConnection)urlconnection;
            httpurlconnection.setInstanceFollowRedirects(false);
        }
        return urlconnection;
    }

    static URL getRedirectedLocation(HttpURLConnection httpurlconnection)
        throws MalformedURLException
    {
        String s = httpurlconnection.getHeaderField("Location");
        return new URL(s);
    }

    static File deriveTempFileLocation(URL url)
        throws IOException
    {
        String s = url.getPath();
        String s1 = FilenameUtils.getName(s);
        return deriveTempFileLocation(s1);
    }

    private static File deriveTempFileLocation(String s)
        throws IOException
    {
        Path path = Files.createTempDirectory("tmp", new FileAttribute[0]);
        String s1 = URLDecoder.decode(s, "utf-8");
        return path.resolve(s1).toFile();
    }

    private static final String LOCATION = "Location";
}
