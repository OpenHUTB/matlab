// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   ManagerInstalledAddOnMetadata.java

package com.mathworks.addons_common;

import com.mathworks.addons_common.util.AddonDateUtils;
import com.mathworks.addons_common.util.ImageUtils;
import com.mathworks.addons_common.util.settings.InstallationFolderUtils;
import com.mathworks.mvm.exec.MvmExecutionException;
import com.mathworks.services.settings.SettingException;
import com.mathworks.util.Log;
import java.awt.image.BufferedImage;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Arrays;
import java.util.Date;

// Referenced classes of package com.mathworks.addons_common:
//            InstalledAddon

public final class ManagerInstalledAddOnMetadata
{

    /**
     * @deprecated Method ManagerInstalledAddOnMetadata is deprecated
     */

    ManagerInstalledAddOnMetadata(String s, String s1, String s2, String s3, String s4, Date date, String s5, 
            String s6, BufferedImage bufferedimage, boolean flag, boolean flag1, String s7, String s8, String as[], 
            String as1[], boolean flag2, boolean flag3, int i, boolean flag4, String as2[], String as3[], 
            String as4[], boolean flag5, boolean flag6, boolean flag7)
    {
        trialDaysRemaining = 0;
        trial = false;
        addOnType = s;
        displayType = s1;
        identifier = s2;
        version = s3;
        installationIdentifier = s4;
        if(date != null)
            installedDate = Long.valueOf(AddonDateUtils.convertDateToMilliseconds(date));
        name = s5;
        authorName = s6;
        imageData = ImageUtils.convertImageToDataUri(bufferedimage);
        isMathworksSupported = flag;
        canUninstall = flag1;
        description = s7;
        summary = s8;
        fileName = (String[])Arrays.copyOf(as, as.length);
        absoluteFilePath = constructAbsolutePathToBeUsedForViewFileListAffordance(as1);
        canOpenFolder = flag2;
        hasDetailPage = flag3;
        trialDaysRemaining = i;
        trial = flag4;
        relatedAddOnIdentifiers = as2;
        relatedAddOnNames = as3;
        additionalActionNames = as4;
        hasDocumentation = flag5;
        enabled = flag6;
        enableDisableSupported = flag7;
    }

    public ManagerInstalledAddOnMetadata(InstalledAddon installedaddon, boolean flag)
    {
        trialDaysRemaining = 0;
        trial = false;
        addOnType = installedaddon.getType();
        displayType = installedaddon.getDisplayType();
        identifier = installedaddon.getIdentifier();
        version = installedaddon.getVersion();
        installationIdentifier = installedaddon.getInstallationIdentifier();
        Date date = installedaddon.getInstalledDate();
        if(date != null)
            installedDate = Long.valueOf(AddonDateUtils.convertDateToMilliseconds(date));
        name = installedaddon.getName();
        authorName = installedaddon.getAuthor();
        imageData = ImageUtils.convertImageToDataUri(installedaddon.getImage());
        isMathworksSupported = installedaddon.isMathworksSupported();
        canUninstall = installedaddon.canUninstall();
        canOpenFolder = installedaddon.canOpenFolder();
        description = installedaddon.getDescription();
        summary = installedaddon.getSummary();
        fileName = (String[])Arrays.copyOf(installedaddon.getFileName(), installedaddon.getFileName().length);
        absoluteFilePath = constructAbsolutePathToBeUsedForViewFileListAffordance(installedaddon.getAbsoluteFilePath());
        hasDetailPage = installedaddon.hasDetailPage();
        trial = installedaddon.isTrial();
        trialDaysRemaining = installedaddon.getTrialDaysRemaining();
        relatedAddOnIdentifiers = installedaddon.getRelatedAddOnIdentifiers();
        relatedAddOnNames = installedaddon.getRelatedAddOnNames();
        additionalActionNames = installedaddon.getCustomActionNames();
        hasDocumentation = installedaddon.hasDocumentation();
        enableDisableSupported = installedaddon.isEnableDisableSupported();
        enabled = flag;
    }

    private String[] constructAbsolutePathToBeUsedForViewFileListAffordance(String as[])
    {
        try
        {
            for(int i = 0; i < as.length; i++)
                as[i] = InstallationFolderUtils.replaceInstallationRootWithRegistrationRoot(Paths.get(as[i], new String[0])).toString();

        }
        catch(Object obj)
        {
            Log.logException(((Exception) (obj)));
        }
        return (String[])Arrays.copyOf(as, as.length);
    }

    public String getName()
    {
        return name;
    }

    public String getIdentifier()
    {
        return identifier;
    }

    public boolean getCanUninstall()
    {
        return canUninstall;
    }

    public boolean getCanOpenFolder()
    {
        return canOpenFolder;
    }

    public String getAddOnType()
    {
        return addOnType;
    }

    public String getDisplayType()
    {
        return displayType;
    }

    public boolean hasDetailPage()
    {
        return hasDetailPage;
    }

    public boolean hasDocumentation()
    {
        return hasDocumentation;
    }

    private final boolean hasDetailPage;
    private String addOnType;
    private String displayType;
    private String identifier;
    private String version;
    private String installationIdentifier;
    private Long installedDate;
    private String name;
    private String authorName;
    private String imageData;
    private boolean isMathworksSupported;
    private boolean canUninstall;
    private String description;
    private String summary;
    private String fileName[];
    private String absoluteFilePath[];
    private boolean canOpenFolder;
    private int trialDaysRemaining;
    private boolean trial;
    private final String relatedAddOnIdentifiers[];
    private final String relatedAddOnNames[];
    private final String additionalActionNames[];
    private final boolean hasDocumentation;
    private final boolean enabled;
    private final boolean enableDisableSupported;
}
