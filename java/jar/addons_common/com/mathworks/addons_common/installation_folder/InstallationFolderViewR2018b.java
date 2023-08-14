// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   InstallationFolderViewR2018b.java

package com.mathworks.addons_common.installation_folder;

import com.mathworks.resources_folder.ResourcesFolderUtils;
import java.nio.file.Path;

// Referenced classes of package com.mathworks.addons_common.installation_folder:
//            InstallationFolderView

public class InstallationFolderViewR2018b extends InstallationFolderView
{

    public InstallationFolderViewR2018b(Path path)
    {
        super(path);
    }

    public Path getCodeFolder()
    {
        return getRootFolder();
    }

    public Path getMetadataFolder()
    {
        return getRootFolder().resolve(ResourcesFolderUtils.getResourcesFolderName());
    }
}
