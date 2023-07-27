// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   AddonManagerUtils.java

package com.mathworks.addons_common.util;

import com.mathworks.html.UrlBuilder;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.awt.image.ImageObserver;
import java.io.File;
import java.io.IOException;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.LinkOption;
import java.nio.file.attribute.BasicFileAttributes;
import java.nio.file.attribute.FileTime;
import java.util.Date;
import javax.swing.ImageIcon;

// Referenced classes of package com.mathworks.addons_common.util:
//            AddonDownloader

public final class AddonManagerUtils
{

    private AddonManagerUtils()
    {
    }

    public static void confirmThereIsOnlyOneAddonIdentifierIn(String as[])
    {
        if(as.length == 0)
            throw new IllegalArgumentException("At least one add-on must be specified.");
        if(as.length > 1)
            throw new UnsupportedOperationException("Installing multiple add-ons at once is not yet supported.");
        else
            return;
    }

    /**
     * @deprecated Method download is deprecated
     */

    public static File download(String s, String s1)
        throws IOException
    {
        return download(s);
    }

    public static File download(String s)
        throws IOException
    {
        UrlBuilder urlbuilder = UrlBuilder.fromString(s);
        URL url = new URL(urlbuilder.toString());
        return AddonDownloader.downloadToTempDir(url);
    }

    public static Date getFileCreationDate(File file)
        throws IOException
    {
        BasicFileAttributes basicfileattributes = Files.readAttributes(file.toPath(), java/nio/file/attribute/BasicFileAttributes, new LinkOption[0]);
        FileTime filetime = basicfileattributes.creationTime();
        return new Date(filetime.toMillis());
    }

    public static BufferedImage convertToImageWithFallback(ImageIcon imageicon, BufferedImage bufferedimage)
    {
        Image image = imageicon.getImage();
        if(null != image && dimensionsNotZeroFor(image))
            return getBufferedImageFrom(imageicon.getImage());
        else
            return bufferedimage;
    }

    private static BufferedImage getBufferedImageFrom(Image image)
    {
        ImageObserver imageobserver = getNoOpImageObserver();
        BufferedImage bufferedimage = new BufferedImage(image.getWidth(imageobserver), image.getHeight(imageobserver), 2);
        Graphics g = bufferedimage.getGraphics();
        Point point = new Point(0, 0);
        g.drawImage(image, point.x, point.y, imageobserver);
        g.dispose();
        return bufferedimage;
    }

    private static boolean dimensionsNotZeroFor(Image image)
    {
        int i = image.getWidth(getNoOpImageObserver());
        int j = image.getHeight(getNoOpImageObserver());
        return i > 0 && j > 0;
    }

    public static ImageObserver getNoOpImageObserver()
    {
        return new ImageObserver() {

            public boolean imageUpdate(Image image, int i, int j, int k, int l, int i1)
            {
                return false;
            }

        }
;
    }

    public static BufferedImage scaleImage(BufferedImage bufferedimage)
    {
        byte byte0 = ((byte)(bufferedimage.getTransparency() != 1 ? 2 : 1));
        int i = bufferedimage.getWidth();
        int j = bufferedimage.getHeight();
        float f = Math.max(160F / (float)i, 115F / (float)j);
        int k = (int)((float)i * f);
        int l = (int)((float)j * f);
        BufferedImage bufferedimage1 = new BufferedImage(k, l, byte0);
        Graphics2D graphics2d = bufferedimage1.createGraphics();
        graphics2d.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BILINEAR);
        graphics2d.drawImage(bufferedimage, 0, 0, k, l, null);
        graphics2d.dispose();
        return bufferedimage1;
    }

    public static BufferedImage getBlankImage()
    {
        BufferedImage bufferedimage = new BufferedImage(BLANK_IMAGE.getWidth(), BLANK_IMAGE.getHeight(), BLANK_IMAGE.getType());
        Graphics2D graphics2d = bufferedimage.createGraphics();
        graphics2d.drawImage(BLANK_IMAGE, 0, 0, null);
        graphics2d.dispose();
        return bufferedimage;
    }

    private static final int IMAGE_WIDTH = 160;
    private static final int IMAGE_HEIGHT = 115;
    public static final BufferedImage BLANK_IMAGE = new BufferedImage(160, 115, 2);

}
