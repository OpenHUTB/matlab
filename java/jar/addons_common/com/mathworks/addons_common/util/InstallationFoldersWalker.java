// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   InstallationFoldersWalker.java

package com.mathworks.addons_common.util;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Collection;
import java.util.HashSet;

// Referenced classes of package com.mathworks.addons_common.util:
//            InstallationFoldersVisitor

public final class InstallationFoldersWalker
{

    private InstallationFoldersWalker()
    {
    }

    public static Collection walkAndRetrieve(Path path, InstallationFoldersVisitor installationfoldersvisitor)
        throws IOException
    {
        HashSet hashset = new HashSet();
        Files.walkFileTree(path, hashset, 3, installationfoldersvisitor);
        return installationfoldersvisitor.getAddOnFiles();
    }
}
