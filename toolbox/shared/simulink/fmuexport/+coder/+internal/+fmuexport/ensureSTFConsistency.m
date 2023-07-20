
function cghwOCObj=ensureSTFConsistency(childModel,topModel)



    msg=message('FMUExport:FMU:FMU2ExpCSParameterResetSystemTarget',childModel);



    coder.internal.fmuexport.reportMsg(msg,'Info',topModel);

    if~bdIsLoaded(childModel);load_system(childModel);end
    configSet=getActiveConfigSet(childModel);
    origDirty=get_param(childModel,'Dirty');






    origCGSettings=configSet.getComponent('Code Generation');
    origHWSettings=configSet.getComponent('Hardware Implementation');
    origObfuscateSettings=get_param(childModel,'ObfuscateCode');
    cghwOCObj=onCleanup(@()restoreSetting(childModel,copy(origCGSettings),copy(origHWSettings),origObfuscateSettings,origDirty));
    configSetTop=getActiveConfigSet(topModel);
    topCGSettings=configSetTop.getComponent('Code Generation');
    configSet.attachComponent(copy(topCGSettings));
    topHWSettings=configSetTop.getComponent('Hardware Implementation');
    configSet.attachComponent(copy(topHWSettings));
    set_param(childModel,'ObfuscateCode',3);


    set_param(childModel,'Dirty',origDirty);

    function restoreSetting(childModel,cgSettingsCopy,hwSettingsCopy,obfuscateSetting,dirtyFlag)

        try
            configSet=getActiveConfigSet(childModel);
            configSet.attachComponent(cgSettingsCopy);
        catch
        end
        try
            configSet=getActiveConfigSet(childModel);
            configSet.attachComponent(hwSettingsCopy);
        catch
        end
        try
            set_param(childModel,'ObfuscateCode',obfuscateSetting);
            set_param(childModel,'Dirty',dirtyFlag);
        catch
        end
    end
end
