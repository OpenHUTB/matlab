function selfPacedTrainingStartup

    connector.ensureServiceOn;
    connectorPath=connector.addStaticContentOnPath('sltraining',learning.simulink.preferences.slacademyprefs.webPath,'SkipCompatibilityList',true);

    learning.simulink.Application.getInstance().setConnectorPath([connectorPath(2:end),'/']);

    com.mathworks.matlab_login.MatlabLogin.initializeLoginServices();


    learning.simulink.Application.getInstance().setUserHotParameterSetting(get_param(0,'EditorSmartEditingHotParam'));
    set_param(0,'EditorSmartEditingHotParam',0)



    learning.simulink.Application.getInstance().setUserFileGenControlConfig(Simulink.fileGenControl('getConfig'));


    cachefolder=fullfile(tempdir,'simulinkselfpaced');
    userCoursePath=fullfile(learning.simulink.preferences.slacademyprefs.Paths.UserPath);

    learning.simulink.internal.util.clearAndResetFolder({
    cachefolder,...
    fullfile(tempdir,'signalCheck'),...
    userCoursePath});

    Simulink.fileGenControl('set','CacheFolder',cachefolder,...
    'CodeGenFolder',cachefolder,...
    'CodeGenFolderStructure',...
    Simulink.filegen.CodeGenFolderStructure.ModelSpecific,...
    'createDir',true);
end