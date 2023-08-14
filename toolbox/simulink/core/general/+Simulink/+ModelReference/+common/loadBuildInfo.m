function buildInfoStruct=loadBuildInfo(buildInfoPath)




    buildInfoFullFile=fullfile(buildInfoPath,'buildInfo.mat');
    buildInfoStruct=load(buildInfoFullFile);



    postLoadUpdate(buildInfoStruct.buildInfo,buildInfoPath);

    if~locBuildInfoHasRequiredVariables(buildInfoStruct)
        DAStudio.error('Simulink:protectedModel:ProtectedModelBuildInfoMissingVariables');
    end



    function out=locBuildInfoHasRequiredVariables(buildInfoStruct)

        varListNames=fieldnames(buildInfoStruct);
        assert(~isempty(varListNames),'BuildInfo is unexpectedly empty');
        out=all(ismember({'buildOpts','buildInfo'},varListNames));

