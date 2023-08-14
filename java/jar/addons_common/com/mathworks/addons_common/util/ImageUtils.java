// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   ImageUtils.java

package com.mathworks.addons_common.util;

import com.mathworks.addons_common.util.settings.GalleryUrlPref;
import com.mathworks.util.Log;
import java.awt.image.BufferedImage;
import java.io.*;
import java.net.URL;
import java.net.URLConnection;
import java.nio.charset.Charset;
import java.nio.file.Path;
import javax.imageio.ImageIO;
import org.apache.commons.codec.binary.Base64;

// Referenced classes of package com.mathworks.addons_common.util:
//            MetadataFileUtils, URLConnectionFactory, AddonManagerUtils

public final class ImageUtils
{

    private ImageUtils()
    {
    }

    public static BufferedImage getImageFor(String s, Path path)
    {
        InputStream inputstream;
        Throwable throwable;
        String s1 = (new StringBuilder()).append(GalleryUrlPref.get()).append("/").append(s).append("/").append("metadata.xml").toString();
        String s2 = MetadataFileUtils.getPreviewImageUrl(new URL(s1));
        URL url = new URL(s2);
        URLConnection urlconnection = URLConnectionFactory.getUrlConnection(url);
        inputstream = urlconnection.getInputStream();
        throwable = null;
        BufferedImage bufferedimage;
        BufferedImage bufferedimage1;
        bufferedimage = ImageIO.read(inputstream);
        if(bufferedimage != null)
            break MISSING_BLOCK_LABEL_131;
        bufferedimage1 = getImage(path);
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
        return bufferedimage1;
        try
        {
            bufferedimage1 = bufferedimage;
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
                catch(Throwable throwable3)
                {
                    throwable.addSuppressed(throwable3);
                }
            else
                inputstream.close();
        return bufferedimage1;
        Exception exception1;
        exception1;
        if(inputstream != null)
            if(throwable != null)
                try
                {
                    inputstream.close();
                }
                catch(Throwable throwable4)
                {
                    throwable.addSuppressed(throwable4);
                }
            else
                inputstream.close();
        throw exception1;
        Exception exception;
        exception;
        return getImage(path);
    }

    static BufferedImage getImage(Path path)
    {
        try
        {
            return ImageIO.read(path.toFile());
        }
        catch(IOException ioexception)
        {
            Log.logException(ioexception);
        }
        return AddonManagerUtils.BLANK_IMAGE;
    }

    public static String convertImageToDataUri(BufferedImage bufferedimage)
    {
        byte abyte0[] = getBytesFrom(bufferedimage);
        String s = new String(Base64.encodeBase64(abyte0), Charset.forName("UTF-8"));
        return (new StringBuilder()).append("data:image/png;base64,").append(s).toString();
    }

    private static byte[] getBytesFrom(BufferedImage bufferedimage)
    {
        ByteArrayOutputStream bytearrayoutputstream = new ByteArrayOutputStream();
        try
        {
            ImageIO.write(bufferedimage, "png", bytearrayoutputstream);
        }
        catch(IOException ioexception)
        {
            Log.logException(ioexception);
        }
        return bytearrayoutputstream.toByteArray();
    }

    private static final String URL_SEPARATOR = "/";
    private static final String METADATA_FILE_NAME = "metadata.xml";
}
