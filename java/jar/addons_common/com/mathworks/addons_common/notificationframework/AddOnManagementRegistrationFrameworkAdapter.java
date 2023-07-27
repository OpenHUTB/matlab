// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   AddOnManagementRegistrationFrameworkAdapter.java

package com.mathworks.addons_common.notificationframework;

import com.mathworks.addons_registry.AddOnsRegistry;
import java.nio.file.Path;

public final class AddOnManagementRegistrationFrameworkAdapter
{

    public AddOnManagementRegistrationFrameworkAdapter()
    {
    }

    static void enableAddOn(String s, String s1)
    {
        AddOnsRegistry.enable(s, s1);
    }

    static void disableAddOn(String s, String s1)
    {
        AddOnsRegistry.disable(s, s1);
    }

    public static void addAddOn(String s, String s1, boolean flag, Path path)
    {
        AddOnsRegistry.add(s, s1, flag, path);
    }

    static void addSupportPackage(String s, String s1)
    {
        AddOnsRegistry.addSupportPackage(s, s1);
    }

    public static void removeAddOn(String s, String s1)
    {
        AddOnsRegistry.remove(s, s1);
    }

    public static void updateAddOn(String s, String s1, boolean flag)
    {
        AddOnsRegistry.update(s, s1, flag);
    }

    public static void updateMathWorksProduct(String s, String s1)
    {
        AddOnsRegistry.updateMathWorksProduct(s, s1);
    }

    static void removeSupportPackage(String s, String s1)
    {
        AddOnsRegistry.removeSupportPackage(s, s1);
    }
}
