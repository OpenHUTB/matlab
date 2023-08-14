// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   OpenUrlMessage.java

package com.mathworks.addons_common;

import com.mathworks.matlabserver.connector.api.Connector;
import java.net.MalformedURLException;
import java.util.HashMap;
import java.util.Map;

/**
 * @deprecated Class OpenUrlMessage is deprecated
 */

public final class OpenUrlMessage
{
    public static class Builder
    {

        public Builder context(String s)
        {
            context = s;
            return this;
        }

        public Builder postMessageTag(String s)
        {
            postMessageTag = s;
            return this;
        }

        public OpenUrlMessage createMessage()
        {
            return new OpenUrlMessage(this);
        }

        private String url;
        private String context;
        private String postMessageTag;




        public Builder(String s)
            throws MalformedURLException
        {
            url = OpenUrlMessage.getLocalUrlAppendedWith(s);
        }
    }


    public String getUrl()
    {
        return url;
    }

    public String getContext()
    {
        return (String)configuration.get("context");
    }

    public String getPostMessageTag()
    {
        return (String)configuration.get("postMessageTag");
    }

    public static Builder getBuilder(String s)
        throws MalformedURLException
    {
        return new Builder(s);
    }

    private OpenUrlMessage(Builder builder)
    {
        url = builder.url;
        configuration = new HashMap();
        configuration.put("context", builder.context);
        configuration.put("postMessageTag", builder.postMessageTag);
    }

    public static String getLocalUrlAppendedWith(String s)
        throws MalformedURLException
    {
        return Connector.getUrl(s);
    }


    private static final String CONFIGURATION_DATA_FIELD_CONTEXT = "context";
    private static final String CONFIGURATION_DATA_FIELD_POSTMESSAGETAG = "postMessageTag";
    private String url;
    private Map configuration;
}
