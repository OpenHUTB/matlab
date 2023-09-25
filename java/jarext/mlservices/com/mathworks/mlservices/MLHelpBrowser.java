// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   MLHelpBrowser.java

package com.mathworks.mlservices;


public interface MLHelpBrowser
{

    public abstract void invoke();

    public abstract void setCurrentLocation(String s);

    public abstract void setCurrentLocationAndHighlightKeywords(String s, String as[]);

    public abstract void showHelpPage(String s, String s1);

    public abstract void showHelpPageAndHighlightKeywords(String s, String s1, String as[]);

    public abstract boolean showProductPage(String s);

    public abstract String getCurrentLocation();

    public abstract void setHtmlText(String s);

    public abstract void setDemoText(String s);

    public abstract void setHtmlTextAndHighlightKeywords(String s, String as[]);

    public abstract String getHtmlText();

    public abstract void docSearch(String s);

    public abstract void showDemos();

    public abstract void showDemos(String s);

    public abstract void showDemos(String s, String s1);

    public abstract void displayTopic(String s, String s1);
}
