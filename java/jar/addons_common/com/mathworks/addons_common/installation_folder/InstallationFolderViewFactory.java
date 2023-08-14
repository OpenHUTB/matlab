// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   InstallationFolderViewFactory.java

package com.mathworks.addons_common.installation_folder;

import java.nio.file.*;

// Referenced classes of package com.mathworks.addons_common.installation_folder:
//            InstallationFolderViewR2018b, InstallationFolderView

public class InstallationFolderViewFactory
{

    public static InstallationFolderView getDefaultView(Path path)
    {
        return new InstallationFolderViewR2018b(path);
    }

    public static InstallationFolderView getViewForExistingFolder(Path path)
    {
        if(!Files.exists(path, new LinkOption[0]))
            return null;
        InstallationFolderViewR2018b installationfolderviewr2018b = new InstallationFolderViewR2018b(path);
        if(Files.exists(installationfolderviewr2018b.getCodeFolder(), new LinkOption[0]) && Files.exists(installationfolderviewr2018b.getMetadataFolder(), new LinkOption[0]))
            return installationfolderviewr2018b;
        else
            return null;
    }

    private InstallationFolderViewFactory()
    {
    }
}
