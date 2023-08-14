// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   BalloonTooltipNotification.java

package com.mathworks.addons_common.notificationframework;

import com.mathworks.addons_common.matlabonline.Communicator;
import com.mathworks.addons_common.matlabonline.MessageFromServer;
import com.mathworks.util.Log;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import javax.imageio.ImageIO;
import javax.xml.bind.DatatypeConverter;

public final class BalloonTooltipNotification
{

    public BalloonTooltipNotification()
    {
    }

    public static void show(String s, String s1, String s2, BufferedImage bufferedimage, String s3, String s4)
    {
        sendMessageToMatlabOnline(s, s1, s2, convertBufferedImageToDataUri(bufferedimage), s3, s4);
    }

    private static void sendMessageToMatlabOnline(String s, String s1, String s2, String s3, String s4, String s5)
    {
        HashMap hashmap = new HashMap();
        hashmap.put("addOnName", s);
        hashmap.put("addOnType", s1);
        hashmap.put("addOnIdentifier", s2);
        hashmap.put("icon", s3);
        hashmap.put("notificationTitle", s4);
        hashmap.put("selectorForTooltipSourceDomNode", s5);
        Communicator.sendMessageToMatlabOnline(MessageFromServer.SHOW_BALLOON_TOOLTIP_NOTIFICATION, hashmap);
    }

    public static void show(String s, String s1, String s2, String s3, String s4)
    {
        sendMessageToMatlabOnline(s, s1, s2, "", s3, s4);
    }

    private static String convertBufferedImageToDataUri(BufferedImage bufferedimage)
    {
        byte abyte0[] = getBytesFrom(bufferedimage);
        return (new StringBuilder()).append("data:image/png;base64,").append(DatatypeConverter.printBase64Binary(abyte0)).toString();
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

    public static final String EMPTY_DATA_FOR_IMAGE_SRC = "";
}
