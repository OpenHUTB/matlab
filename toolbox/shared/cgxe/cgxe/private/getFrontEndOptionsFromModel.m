function[feOpts,customInclude,importCustomCode]=getFrontEndOptionsFromModel(modelH)
    modelName=get_param(modelH,'Name');

    customCodeSettings=CGXE.CustomCode.CustomCodeSettings.createFromModel(modelName);

    projRootDir=get_cgxe_proj_root();
    modelRefRebuildModelRootDir=[];
    reportTokenizerError=true;

    [customCodeSettings.userIncludeDirs,...
    customCodeSettings.userSources,...
    customCodeSettings.userLibraries]=...
    getTokenizedPathsAndFiles(modelName,projRootDir,customCodeSettings,pwd,modelRefRebuildModelRootDir,reportTokenizerError);

    if customCodeSettings.isCpp
        lang='C++';
    else
        lang='C';
    end
    useCached=~strcmpi(get_param(modelName,'SimulationStatus'),'stopped');
    feOpts=CGXE.CustomCode.getFrontEndOptions(lang,customCodeSettings.userIncludeDirs,customCodeSettings.customUserDefines,{},useCached,true);
    customInclude=customCodeSettings.customCode;
    importCustomCode=customCodeSettings.parseCC;

end

