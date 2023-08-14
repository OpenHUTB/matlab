// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   InstallationFolderUtils.java

package com.mathworks.addons_common.util.settings;

import com.mathworks.addons_common.util.MatlabPlatformUtil;
import com.mathworks.mvm.exec.MvmExecutionException;
import com.mathworks.services.settings.*;
import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

// Referenced classes of package com.mathworks.addons_common.util.settings:
//            InstallLocation, AddOnsSettingsUtils

public final class InstallationFolderUtils
{

    private InstallationFolderUtils()
    {
    }

    /**
     * @deprecated Method getInstallationFolder is deprecated
     */

    public static Path getInstallationFolder()
        throws InterruptedException, SettingException, MvmExecutionException
    {
        return InstallLocation.getInstallationRoot();
    }

    public static void initializeSetting()
        throws SettingException, MvmExecutionException, InterruptedException, IOException
    {
        if(!MatlabPlatformUtil.isMatlabOnline() && isSettingEmpty())
            setInstallationFolder(getDefaultInstallationFolder());
    }

    public static Path getDefaultInstallationFolder()
        throws MvmExecutionException, InterruptedException
    {
        return InstallLocation.getInstance().getDefaultInstallationFolder();
    }

    /**
     * @deprecated Method setInstallationFolder is deprecated
     */

    public static void setInstallationFolder(Path path)
        throws IOException, MvmExecutionException, InterruptedException, SettingException
    {
        Path path1 = path.toAbsolutePath();
        if(isNewValueForTheSetting(path1))
        {
            Setting setting = getInstallationFolderSetting();
            setting.set(path1.toString(), SettingLevel.USER);
        }
    }

    public static boolean isSettingEmpty()
        throws SettingNotFoundException, SettingTypeException
    {
        Setting setting = getInstallationFolderSetting();
        return ((String)setting.get()).isEmpty();
    }

    static Setting getInstallationFolderSetting()
        throws SettingNotFoundException, SettingTypeException
    {
        return AddOnsSettingsUtils.getSetting(java/lang/String, "InstallationFolder");
    }

    static boolean isNewValueForTheSetting(Path path)
        throws SettingException, MvmExecutionException, InterruptedException
    {
        return isSettingEmpty() || !path.equals(getInstallationFolder());
    }

    /**
     * @deprecated Method initializeWritableAndReadOnlyInstallLocation is deprecated
     */

    public static void initializeWritableAndReadOnlyInstallLocation(String s, String s1)
    {
        InstallLocation.getInstance().setInstallationRoot(Paths.get(s, new String[0]));
        InstallLocation.getInstance().setRegistrationRoot(Paths.get(s1, new String[0]));
    }

    /**
     * @deprecated Method getReadOnlyInstallLocation is deprecated
     */

    public static Path getReadOnlyInstallLocation()
        throws InterruptedException, SettingTypeException, SettingNotFoundException, MvmExecutionException
    {
        return InstallLocation.getRegistrationRoot();
    }

    /**
     * @deprecated Method replaceWritableInstallLocationWithReadOnlyInstallLocation is deprecated
     */

    public static Path replaceWritableInstallLocationWithReadOnlyInstallLocation(Path path)
        throws InterruptedException, MvmExecutionException, SettingException
    {
        return replaceInstallationRootWithRegistrationRoot(path);
    }

    public static Path replaceInstallationRootWithRegistrationRoot(Path path)
        throws InterruptedException, MvmExecutionException, SettingException
    {
        String s = InstallLocation.getInstallationRoot().toString();
        String s1 = InstallLocation.getRegistrationRoot().toString();
        Path path1 = Paths.get(path.toString().replaceFirst(Pattern.quote(s), Matcher.quoteReplacement(s1)), new String[0]);
        return path1;
    }

    private static final String SETTING_KEY = "InstallationFolder";
}
