// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   FolderRegistry.java

package com.mathworks.addons_common.notificationframework;

import com.mathworks.addons_common.InstalledAddon;
import com.mathworks.addons_common.exceptions.*;
import com.mathworks.addons_common.legacy_format_support.InstalledAddonGenerator;
import com.mathworks.mvm.context.MvmContext;
import com.mathworks.services.settings.*;
import com.mathworks.util.Log;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.*;

public final class FolderRegistry
{

    public FolderRegistry()
    {
    }

    static synchronized void add(String s, String s1, boolean flag, Path path)
    {
        String s2 = deriveSettingKeyFromIdentifier(s);
        String s3 = deriveSettingKeyFromVersion(s1);
        try
        {
            SettingPath settingpath = getMVMSettingPath();
            if(!hasChildWithName(settingpath, "folderRegistry"))
                settingpath.addNode("folderRegistry");
            SettingPath settingpath1 = retrieveFolderRegistrySettingPath();
            if(hasEntryWithIdentifierAndVersion(s, s1))
                remove(s, s1);
            if(!hasChildWithName(settingpath1, s2))
                settingpath1.addNode(s2, true);
            SettingPath settingpath2 = new SettingPath(settingpath1, new String[] {
                s2
            });
            SettingPath settingpath3 = settingpath2.addNode(s3);
            Setting setting = settingpath3.addSetting("installedFolder", java/lang/String, SettingLevel.USER);
            setting.set(path.toString());
            if(flag)
                setEnabledVersionForAddOn(s1, settingpath2);
        }
        catch(SettingException settingexception)
        {
            Log.logException(settingexception);
        }
    }

    static synchronized void remove(String s)
    {
        String s1 = deriveSettingKeyFromIdentifier(s);
        try
        {
            SettingPath settingpath = retrieveFolderRegistrySettingPath();
            settingpath.delete(s1);
        }
        catch(SettingNotFoundException settingnotfoundexception)
        {
            Log.logException(settingnotfoundexception);
        }
        catch(SettingException settingexception)
        {
            Log.logException(settingexception);
        }
    }

    static synchronized void remove(String s, String s1)
    {
        String s2 = deriveSettingKeyFromIdentifier(s);
        String s3 = deriveSettingKeyFromVersion(s1);
        try
        {
            SettingPath settingpath = retrieveFolderRegistrySettingPath();
            SettingPath settingpath1 = new SettingPath(settingpath, new String[] {
                s2
            });
            settingpath1.delete(s3);
            if(hasChildWithName(settingpath1, "enabledVersion"))
            {
                Setting setting = new Setting(settingpath1, java/lang/String, "enabledVersion");
                if(((String)setting.get()).toLowerCase().equals(s1.toLowerCase()))
                    setting.delete();
            }
            if(settingpath1.getChildPaths().isEmpty())
                settingpath.delete(s2);
        }
        catch(SettingNotFoundException settingnotfoundexception) { }
        catch(SettingException settingexception)
        {
            Log.logException(settingexception);
        }
    }

    static synchronized void update(String s, String s1, boolean flag)
    {
        try
        {
            SettingPath settingpath = retrieveFolderRegistrySettingPath();
            String s2 = deriveSettingKeyFromIdentifier(s);
            SettingPath settingpath1 = new SettingPath(settingpath, new String[] {
                s2
            });
            if(isEnabled(s, s1) && !flag)
            {
                Setting setting = new Setting(settingpath1, java/lang/String, "enabledVersion");
                setting.delete();
            } else
            if(flag)
                setEnabledVersionForAddOn(s1, settingpath1);
        }
        catch(SettingException settingexception) { }
        catch(AddOnNotFoundException addonnotfoundexception)
        {
            Log.logException(addonnotfoundexception);
        }
    }

    private static void setEnabledVersionForAddOn(String s, SettingPath settingpath)
        throws SettingNotFoundException, SettingNameDuplicationException, SettingValidationException, SettingAccessException, SettingTypeException
    {
        if(!hasChildWithName(settingpath, "enabledVersion"))
            settingpath.addSetting("enabledVersion", java/lang/String, SettingLevel.USER);
        Setting setting = new Setting(settingpath, java/lang/String, "enabledVersion");
        setting.set(s);
    }

    private static String deriveSettingKeyFromIdentifier(String s)
    {
        String s1 = s.replace("-", "_");
        return "artifact_".concat(s1);
    }

    private static String deriveSettingKeyFromVersion(String s)
    {
        String s1 = s.replace(".", "_");
        return "v_".concat(s1);
    }

    private static boolean hasChildWithName(SettingPath settingpath, String s)
        throws SettingNotFoundException
    {
        String as[] = settingpath.getChildNames();
        return Arrays.asList(as).contains(s);
    }

    private static SettingPath getMVMSettingPath()
    {
        com.mathworks.mvm.MVM mvm = MvmContext.get();
        return new SettingPath(mvm);
    }

    private static SettingPath retrieveFolderRegistrySettingPath()
        throws SettingNotFoundException, SettingNameDuplicationException
    {
        SettingPath settingpath = getMVMSettingPath();
        return new SettingPath(settingpath, new String[] {
            "folderRegistry"
        });
    }

    static synchronized void deleteFolderRegistrySettingPath()
    {
        try
        {
            SettingPath settingpath = getMVMSettingPath();
            settingpath.delete("folderRegistry");
        }
        catch(SettingNotFoundException settingnotfoundexception) { }
        catch(SettingException settingexception)
        {
            Log.logException(settingexception);
        }
    }

    static synchronized boolean hasEntryWithIdentifier(String s)
    {
        String s1 = deriveSettingKeyFromIdentifier(s);
        try
        {
            SettingPath settingpath = retrieveFolderRegistrySettingPath();
            return hasChildWithName(settingpath, s1);
        }
        catch(SettingNotFoundException settingnotfoundexception)
        {
            return false;
        }
        catch(SettingException settingexception)
        {
            Log.logException(settingexception);
        }
        return false;
    }

    public static synchronized boolean hasEntryWithIdentifierAndVersion(String s, String s1)
    {
        String s2 = deriveSettingKeyFromIdentifier(s);
        String s3 = deriveSettingKeyFromVersion(s1);
        if(hasEntryWithIdentifier(s))
        {
            try
            {
                SettingPath settingpath = retrieveFolderRegistrySettingPath();
                SettingPath settingpath1 = new SettingPath(settingpath, new String[] {
                    s2
                });
                return hasChildWithName(settingpath1, s3);
            }
            catch(SettingNotFoundException settingnotfoundexception)
            {
                return false;
            }
            catch(SettingException settingexception)
            {
                Log.logException(settingexception);
            }
            return false;
        } else
        {
            return false;
        }
    }

    public static synchronized boolean hasMultipleVersionsInstalled(String s)
        throws SettingNotFoundException
    {
        int i = 0;
        if(hasEntryWithIdentifier(s))
        {
            String s1 = deriveSettingKeyFromIdentifier(s);
            SettingPath settingpath = new SettingPath(MvmContext.get(), new String[] {
                "folderRegistry", s1
            });
            String as[] = settingpath.getChildNames();
            int j = as.length;
            for(int k = 0; k < j; k++)
            {
                String s2 = as[k];
                if(!s2.equalsIgnoreCase("enabledVersion") && ++i > 1)
                    return true;
            }

        }
        return false;
    }

    static synchronized boolean isEnabled(String s, String s1)
        throws AddOnNotFoundException
    {
        String s2 = deriveSettingKeyFromIdentifier(s);
        if(hasEntryWithIdentifierAndVersion(s, s1))
        {
            try
            {
                SettingPath settingpath = retrieveFolderRegistrySettingPath();
                SettingPath settingpath1 = new SettingPath(settingpath, new String[] {
                    s2
                });
                boolean flag = false;
                if(hasChildWithName(settingpath1, "enabledVersion"))
                {
                    Setting setting = new Setting(settingpath1, java/lang/String, "enabledVersion");
                    if(((String)setting.get()).equalsIgnoreCase(s1))
                        flag = true;
                }
                return flag;
            }
            catch(SettingNotFoundException settingnotfoundexception)
            {
                return false;
            }
            catch(SettingException settingexception)
            {
                Log.logException(settingexception);
            }
            return false;
        } else
        {
            throw new AddOnNotFoundException(s, s1);
        }
    }

    public static synchronized Path getInstalledFolderForAddOn(String s, String s1)
        throws AddOnNotFoundException
    {
        String s2 = deriveSettingKeyFromIdentifier(s);
        String s3 = deriveSettingKeyFromVersion(s1);
        if(hasEntryWithIdentifierAndVersion(s, s1))
            try
            {
                SettingPath settingpath = retrieveFolderRegistrySettingPath();
                SettingPath settingpath1 = new SettingPath(settingpath, new String[] {
                    s2
                });
                SettingPath settingpath2 = new SettingPath(settingpath1, new String[] {
                    s3
                });
                Setting setting = new Setting(settingpath2, java/lang/String, "installedFolder");
                return Paths.get((String)setting.get(), new String[0]);
            }
            catch(SettingException settingexception)
            {
                Log.logException(settingexception);
            }
        throw new AddOnNotFoundException(s, s1);
    }

    public static synchronized boolean hasEnabledVersion(String s)
        throws IdentifierNotFoundException
    {
        String s1;
        s1 = deriveSettingKeyFromIdentifier(s);
        if(!hasEntryWithIdentifier(s))
            break MISSING_BLOCK_LABEL_74;
        SettingPath settingpath = retrieveFolderRegistrySettingPath();
        SettingPath settingpath1 = new SettingPath(settingpath, new String[] {
            s1
        });
        if(hasChildWithName(settingpath1, "enabledVersion"))
        {
            Setting setting = new Setting(settingpath1, java/lang/String, "enabledVersion");
            return setting.isSet(SettingLevel.USER);
        }
        try
        {
            return false;
        }
        catch(SettingException settingexception)
        {
            Log.logException(settingexception);
        }
        return false;
        throw new IdentifierNotFoundException(s);
    }

    static synchronized String getEnabledVersion(String s)
        throws SettingException
    {
        String s1 = deriveSettingKeyFromIdentifier(s);
        SettingPath settingpath = retrieveFolderRegistrySettingPath();
        SettingPath settingpath1 = new SettingPath(settingpath, new String[] {
            s1
        });
        Setting setting = new Setting(settingpath1, java/lang/String, "enabledVersion");
        return (String)setting.get();
    }

    static synchronized InstalledAddon[] retrieveAllInstalledAddons()
    {
        ArrayList arraylist = new ArrayList();
        try
        {
            if(registryExists())
            {
                SettingPath settingpath = retrieveFolderRegistrySettingPath();
                String as[] = settingpath.getChildNames();
                String as1[] = as;
                int i = as1.length;
                for(int j = 0; j < i; j++)
                {
                    String s = as1[j];
                    SettingPath settingpath1 = new SettingPath(settingpath, new String[] {
                        s
                    });
                    String s1 = "";
                    if(hasChildWithName(settingpath1, "enabledVersion"))
                    {
                        Setting setting = new Setting(settingpath1, java/lang/String, "enabledVersion");
                        s1 = (String)setting.get();
                    }
                    String as2[] = settingpath1.getChildNames();
                    String as3[] = as2;
                    int k = as3.length;
                    for(int l = 0; l < k; l++)
                    {
                        String s2 = as3[l];
                        if(s2.equals("enabledVersion"))
                            continue;
                        SettingPath settingpath2 = new SettingPath(settingpath1, new String[] {
                            s2
                        });
                        Setting setting1 = new Setting(settingpath2, java/lang/String, "installedFolder");
                        try
                        {
                            InstalledAddon installedaddon = InstalledAddonGenerator.generateInstalledAddon(Paths.get((String)setting1.get(), new String[0]));
                            if(installedaddon.getVersion().equals(s1))
                                installedaddon.setEnabled(true);
                            else
                                installedaddon.setEnabled(false);
                            arraylist.add(installedaddon);
                        }
                        catch(InstalledAddonConversionException installedaddonconversionexception) { }
                    }

                }

            }
        }
        catch(SettingException settingexception)
        {
            Log.logException(settingexception);
            return new InstalledAddon[0];
        }
        return (InstalledAddon[])arraylist.toArray(new InstalledAddon[0]);
    }

    static synchronized boolean registryExists()
    {
        try
        {
            SettingPath settingpath = getMVMSettingPath();
            return hasChildWithName(settingpath, "folderRegistry");
        }
        catch(Exception exception)
        {
            Log.logException(exception);
        }
        return false;
    }

    private static final String FOLDER_REGISTRY_SETTING_PATH = "folderRegistry";
    private static final String INSTALLED_FOLDER = "installedFolder";
    private static final String ENABLED_VERSION = "enabledVersion";
    private static final String SETTINGS_KEY_PREFIX = "artifact_";
    private static final String VERSION_SETTINGS_KEY_PREFIX = "v_";
}
