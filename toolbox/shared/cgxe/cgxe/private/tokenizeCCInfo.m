function[ccInfo]=tokenizeCCInfo(ccInfo,modelName,projRootDir,modelRefRebuildModelRootDir,reportTokenizerError)







    if nargin<5
        reportTokenizerError=true;
    end

    if nargin<4
        modelRefRebuildModelRootDir='';
    end

    if nargin<3
        projRootDir='';
    end

    if isempty(ccInfo)||ccInfo.isTokenized
        return;
    end

    useCachedFEOption=false;

    if~isempty(modelName)
        useCachedFEOption=~strcmpi(get_param(modelName,'SimulationStatus'),'stopped');
    elseif(~isempty(modelRefRebuildModelRootDir))

        useCachedFEOption=true;
    end

    ccDir='';



    if isempty(projRootDir)
        [projRootDir,~]=get_cgxe_proj_root();
        ccDir=fullfile(projRootDir,'slprj','_slcc',ccInfo.settingsChecksum);
    end


    [ccInfo.customCodeSettings.userIncludeDirs,...
    ccInfo.customCodeSettings.userSources,...
    ccInfo.customCodeSettings.userLibraries,userSourcesRawTokens]=...
    cgxeprivate('getTokenizedPathsAndFiles',modelName,projRootDir,...
    ccInfo.customCodeSettings,ccDir,modelRefRebuildModelRootDir,reportTokenizerError);
    ccInfo.userSourcesRawTokens=userSourcesRawTokens;


    dllFullPath='';
    ccLibName=CGXE.CustomCode.getCustomCodeLibFullName(ccInfo.settingsChecksum,'dynamic');
    dllFullPath=fullfile(projRootDir,'slprj','_slcc',ccInfo.settingsChecksum,ccLibName);
    if~isfile(dllFullPath)
        dllFullPath='';
    end
    ccInfo.dllFullPath=dllFullPath;

    ccInfo.feOpts=CGXE.CustomCode.getFrontEndOptions(ccInfo.lang,ccInfo.customCodeSettings.userIncludeDirs,...
    ccInfo.customCodeSettings.customUserDefines,{},useCachedFEOption);

    ccInfo.isTokenized=true;

end