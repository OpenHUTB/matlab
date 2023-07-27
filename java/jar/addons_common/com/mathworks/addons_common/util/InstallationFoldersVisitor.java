// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   InstallationFoldersVisitor.java

package com.mathworks.addons_common.util;

import java.nio.file.SimpleFileVisitor;
import java.util.LinkedHashSet;
import java.util.Set;

public abstract class InstallationFoldersVisitor extends SimpleFileVisitor
{

    public InstallationFoldersVisitor()
    {
        addOnFiles = new LinkedHashSet();
    }

    public Set getAddOnFiles()
    {
        return addOnFiles;
    }

    protected Set addOnFiles;
}
