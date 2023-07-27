// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   AddOnsWindowState.java

package com.mathworks.addons_common.matlabonline;


/**
 * @deprecated Class AddOnsWindowState is deprecated
 */

public final class AddOnsWindowState
{

    public AddOnsWindowState()
    {
    }

    public static boolean isManagerOpen()
    {
        return isManagerOpen;
    }

    public static boolean isExplorerOpen()
    {
        return isExplorerOpen;
    }

    public static void setIsManagerOpen(boolean flag)
    {
        isManagerOpen = flag;
    }

    public static void setIsExplorerOpen(boolean flag)
    {
        isExplorerOpen = flag;
    }

    private static boolean isManagerOpen = false;
    private static boolean isExplorerOpen = false;

}
