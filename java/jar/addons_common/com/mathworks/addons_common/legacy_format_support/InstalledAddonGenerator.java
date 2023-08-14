// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   InstalledAddonGenerator.java

package com.mathworks.addons_common.legacy_format_support;

import com.mathworks.addons_common.InstalledAddon;
import com.mathworks.addons_common.exceptions.InstalledAddonConversionException;
import com.mathworks.addons_common.util.InstalledAddonMetadataUtils;
import com.mathworks.resources_folder.ResourcesFolderUtils;
import com.mathworks.util.*;
import java.nio.file.Path;
import java.util.Collection;

// Referenced classes of package com.mathworks.addons_common.legacy_format_support:
//            InstalledFolderToInstalledAddonConverter

public final class InstalledAddonGenerator
{

    private InstalledAddonGenerator()
    {
    }

    public static InstalledAddon generateInstalledAddon(Path path)
        throws InstalledAddonConversionException
    {
        initializeConverters();
        try
        {
            if(ResourcesFolderUtils.hasResourcesSupport(path))
            {
                InstalledAddon installedaddon = InstalledAddonMetadataUtils.metadataFolderToInstalledAddon(path.toFile(), path.toString());
                if(installedaddon != null)
                    return installedaddon;
            }
        }
        catch(Exception exception)
        {
            Log.logException(exception);
        }
        throw new InstalledAddonConversionException(path.toString());
    }

    private static void initializeConverters()
    {
        if(converters == null)
            converters = ImplementorsCacheFactory.getInstance().getImplementors(com/mathworks/addons_common/legacy_format_support/InstalledFolderToInstalledAddonConverter);
    }

    private static Collection converters = null;

}
