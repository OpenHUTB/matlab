function slrealtimesettings()










    tree=createTree();



    upgraders=createUpgraders();


    factoryFile=fullfile(matlabroot,'toolbox','slrealtime','slrealtime','resources','slrealtime');
    matlab.settings.internal.saveFactoryFile(factoryFile,tree,upgraders);
end

function slrealtime=createTree()

    stringValidator=matlab.settings.internal.SettingValueValidator;
    stringValidator.MustBeString=true;
    stringValidator.MinVectorSize=0;
    stringValidator.MaxVectorSize=100;

    numericValidator=matlab.settings.internal.SettingValueValidator;
    numericValidator.MustBeNumeric=true;
    numericValidator.MinVectorSize=0;
    numericValidator.MaxVectorSize=100;

    slrealtime=matlab.settings.FactoryGroup.createToolboxGroup("slrealtime");
    slrealtime.addSetting("defaultTargetName","ValidationFcn",@matlab.settings.mustBeStringScalar);

    targets=slrealtime.addGroup("targets");

    t_name=targets.addSetting("name");
    matlab.settings.internal.addSettingValueValidator(t_name,stringValidator);

    t_address=targets.addSetting("address");
    matlab.settings.internal.addSettingValueValidator(t_address,stringValidator);

    t_sshPort=targets.addSetting("sshPort");
    matlab.settings.internal.addSettingValueValidator(t_sshPort,numericValidator);

    t_xcpPort=targets.addSetting("xcpPort");
    matlab.settings.internal.addSettingValueValidator(t_xcpPort,numericValidator);

    t_username=targets.addSetting("username");
    matlab.settings.internal.addSettingValueValidator(t_username,stringValidator);

    t_userPassword=targets.addSetting("userPassword");
    matlab.settings.internal.addSettingValueValidator(t_userPassword,stringValidator);

    t_rootPassword=targets.addSetting("rootPassword");
    matlab.settings.internal.addSettingValueValidator(t_rootPassword,stringValidator);

    targetComputerManager=slrealtime.addGroup("targetComputerManager");

    targetOrder=targetComputerManager.addSetting("targetOrder");
    matlab.settings.internal.addSettingValueValidator(targetOrder,stringValidator);

    positions=targetComputerManager.addGroup("positions");

    name=positions.addSetting("name");
    matlab.settings.internal.addSettingValueValidator(name,stringValidator);

    numericValidator.MaxVectorSize=400;
    t_position=positions.addSetting("position");
    matlab.settings.internal.addSettingValueValidator(t_position,numericValidator);

    appgen=slrealtime.addGroup("slrtAppGenerator");

    recentFiles=appgen.addGroup("newRecentFiles");

    recentFilesIcon=recentFiles.addSetting("iconFile");
    matlab.settings.internal.addSettingValueValidator(recentFilesIcon,stringValidator);

    recentFilesTag=recentFiles.addSetting("tag");
    matlab.settings.internal.addSettingValueValidator(recentFilesTag,stringValidator);

    recentFilesText=recentFiles.addSetting("text");
    matlab.settings.internal.addSettingValueValidator(recentFilesText,stringValidator);

    recentFilesDesc=recentFiles.addSetting("description");
    matlab.settings.internal.addSettingValueValidator(recentFilesDesc,stringValidator);

    recentFiles=appgen.addGroup("openRecentFiles");

    recentFilesIcon=recentFiles.addSetting("iconFile");
    matlab.settings.internal.addSettingValueValidator(recentFilesIcon,stringValidator);

    recentFilesTag=recentFiles.addSetting("tag");
    matlab.settings.internal.addSettingValueValidator(recentFilesTag,stringValidator);

    recentFilesText=recentFiles.addSetting("text");
    matlab.settings.internal.addSettingValueValidator(recentFilesText,stringValidator);

    recentFilesDesc=recentFiles.addSetting("description");
    matlab.settings.internal.addSettingValueValidator(recentFilesDesc,stringValidator);
end

function upgraders=createUpgraders()



    upgraders=matlab.settings.SettingsFileUpgrader("v1");
end

