function buildResults=emcGenMakefileAndBuild(bldParams)





    checkArgs(bldParams);
    configInfo=bldParams.configInfo;
    target=getCodingTargetFromConfig(configInfo);
    buildResults=cell(4,1);
    switch target
    case 'mex'
        buildResults=locBuildMEX(buildResults,bldParams);
    case{'rtw','rtw:lib','rtw:dll','rtw:exe'}
        buildResults=locBuildRTW(buildResults,bldParams,target);
    otherwise
        error(message('Coder:buildProcess:unrecognizedTarget'));
    end
end


function buildResults=locBuildMEX(buildResults,bldParams)
    configInfo=bldParams.configInfo;
    if isa(configInfo,'coder.MexCodeConfig')||isa(configInfo,'coder.MexConfig')
        bldMode=coder.internal.BuildMode.Normal;
        buildResults{1}=emcBuildMEX(bldParams,bldMode);
    else
        error(message('Coder:buildProcess:unrecognizedTarget'));
    end
end


function buildResults=locBuildRTW(buildResults,bldParams,target)

    function b=isGenerateExampleMain()
        b=isprop(configInfo,'GenerateExampleMain');
        if b
            b=strcmp(configInfo.GenerateExampleMain,'GenerateCodeAndCompile');
        end




        isClassAsEntrypoint=bldParams.project.IsClassAsEntrypoint;
        b=b&~isClassAsEntrypoint;
    end


    configInfo=bldParams.configInfo;
    buildResults{1}=emcBuildRTW(bldParams,coder.internal.BuildMode.Normal);
    OriginBuildInfo=bldParams.buildInfo.copy;
    if isGenerateExampleMain()&&~strcmp(target,'rtw:exe')
        normalBuildInfo=bldParams.buildInfo;
        bldParams.buildInfo=OriginBuildInfo;

        buildResults=locBuildExample(buildResults,bldParams);
        bldParams.buildInfo=normalBuildInfo;
    end
end


function buildResults=locBuildExample(buildResults,bldParams)
    configInfo=bldParams.configInfo;
    if strcmp(configInfo.GenerateExampleMain,'GenerateCodeAndCompile')
        buildMode=coder.internal.BuildMode.Example;
        buildResults{2}=emcBuildRTW(bldParams,buildMode);
    end
end


function checkArgs(bldParams)

    if nargin~=1
        error(message('Coder:buildProcess:missingBuildInfoOrTflControl'));
    end
    if~isa(bldParams.project,'coder.internal.Project')
        error(message('Coder:buildProcess:expectedProjectArgument'));
    end
    if~isa(bldParams.buildInfo,'RTW.BuildInfo')
        error(message('Coder:buildProcess:expectedBuildInfoArgument'));
    end

    if~isempty(bldParams.tflControl)&&~isa(bldParams.tflControl,'RTW.TflControl')
        error(message('Coder:buildProcess:expectedTflControlArgument'));
    end

    srcFiles=bldParams.buildInfo.getSourceFiles(true,true);
    if isempty(srcFiles)
        error(message('Coder:buildProcess:nothingToBuild'));
    end
end
