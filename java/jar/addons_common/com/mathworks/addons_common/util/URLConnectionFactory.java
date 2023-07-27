// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   URLConnectionFactory.java

package com.mathworks.addons_common.util;

import com.mathworks.webproxy.ProxyConfiguration;
import com.mathworks.webproxy.WebproxyFactory;
import java.io.IOException;
import java.net.URL;
import java.net.URLConnection;

final class URLConnectionFactory
{

    private URLConnectionFactory()
    {
    }

    static URLConnection getUrlConnection(URL url)
        throws IOException
    {
        ProxyConfiguration proxyconfiguration = WebproxyFactory.createDefaultProxyConfiguration(WebproxyFactory.createSystemProxySettings());
        java.net.Proxy proxy = proxyconfiguration.findProxyForURL(url);
        URLConnection urlconnection = url.openConnection(proxy);
        urlconnection.setConnectTimeout(5000);
        urlconnection.setReadTimeout(5000);
        return urlconnection;
    }

    private static final int TIMEOUT = 5000;
}
