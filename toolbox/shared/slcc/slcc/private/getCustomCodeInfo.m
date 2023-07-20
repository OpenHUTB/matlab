function[feOptions,customCodeSource,customCodeHeader,userSources,...
    userDLLPaths,librarySymbols,defaultArrayLayout,functionNameToArrayLayout,...
    customCodeUndefinedFunction,isUseCodeCoverage,isUseOOP,cFeOptions,cxxFeOptions,globalsAsFcnIO]...
    =getCustomCodeInfo(modelName,rtwTypesIncludePath)





    if(~ischar(modelName))
        modelName=get_param(modelName,'Name');
    end




    customCodeSettings=CGXE.CustomCode.CustomCodeSettings.createFromModel(modelName);

    customCodeHeader=customCodeSettings.customCode;
    if~isempty(customCodeSettings.customSourceCode)
        customCodeSource=customCodeSettings.getCustomCodeFromSettings();
    else
        customCodeSource='';
    end

    projRootDir=cgxeprivate('get_cgxe_proj_root');
    targetDir=pwd;


    [fileNameInfo.userIncludeDirs,fileNameInfo.userSources,...
    fileNameInfo.userLibraries]=...
    cgxeprivate('getTokenizedPathsAndFiles',modelName,projRootDir,customCodeSettings,targetDir);


    lang=get_param(modelName,'SimTargetLang');
    includeDirs=[fileNameInfo.userIncludeDirs,rtwTypesIncludePath];


    [cFeOptions,cxxFeOptions]=CGXE.CustomCode.getAllFrontEndOptions(lang,includeDirs,customCodeSettings.customUserDefines);


    if strcmpi(lang,'c')
        feOptions=cFeOptions;
    else
        feOptions=cxxFeOptions;
    end


    feOptions=deepCopy(feOptions);

    userSources=fileNameInfo.userSources;
    userLibraries=fileNameInfo.userLibraries;
    allLibraries=cgxeprivate('addMissingPartnerLibraries',userLibraries);
    userDLLs=cgxeprivate('getLinkAndRuntimeLibs',allLibraries);
    userDLLPaths=unique(cellfun(@fileparts,userDLLs,'UniformOutput',false));
    librarySymbols={};

    if~isempty(userLibraries)
        librarySymbols=CGXE.CustomCode.extractLibrarySymbols(allLibraries);
    end

    defaultArrayLayout=customCodeSettings.defaultFunctionArrayLayout;
    functionNameToArrayLayout=customCodeSettings.functionNameToArrayLayout;
    customCodeUndefinedFunction=customCodeSettings.customCodeUndefinedFunction;
    isUseCodeCoverage=customCodeSettings.analyzeCC;
    isUseOOP=customCodeSettings.debugExecuteCC;
    globalsAsFcnIO=customCodeSettings.customCodeGlobalsAsFunctionIO;

end


