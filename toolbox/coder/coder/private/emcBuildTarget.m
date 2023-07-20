function buildResults=emcBuildTarget(bldParams)





    if usejava('swing')


        com.mathworks.toolbox.coder.app.MatlabJavaNotifier.publishGlobally('CODEGEN_BUILD_PHASE_STARTING');
    end
    bldParams.canWriteCodeDescriptor=emcCanWriteCodeDescriptor(bldParams);
    checkArgs(bldParams);
    setup_buildinfo(bldParams);
    setup_nvtx(bldParams);
    bldParams=serializeCoderAssumptions(bldParams);
    injectDesignRanges(bldParams);
    bldParams=emcSaveBuildInfo(bldParams);
    buildResults=emcGenMakefileAndBuild(bldParams);
end


function bldParams=serializeCoderAssumptions(bldParams)
    if shouldSerializeCoderAssumptions(bldParams)
        if~bldParams.canWriteCodeDescriptor
            bldParams=emcCantWriteCodeDescriptorWarning(bldParams);
            return
        end

        configInterface=coder.connectivity.MATLABConfig(bldParams.configInfo,...
        bldParams.project.Name);
        coder.assumptions.CoderAssumptions.serializeCoderAssumptionsToCodeDescriptor(...
        configInterface,bldParams.project.BldDirectory);
    end
end


function injectDesignRanges(bldParams)





    if isempty(bldParams.codeInfo.OutputFunctions)

        return;
    end
    for actualArg=bldParams.codeInfo.OutputFunctions(1).ActualArgs
        varName=actualArg.GraphicalName;
        if isfield(bldParams.designRanges,varName)
            if~isprop(actualArg,'MinMax')
                prop=addprop(actualArg,'MinMax');
                prop.Hidden=true;
                actualArg.MinMax={[],[]};
            end
            actualArg.MinMax=bldParams.designRanges.(varName);
        end
    end
end


function setup_buildinfo(bldParams)
    codingTarget=getCodingTargetFromConfig(bldParams.configInfo);
    cfgSettings=bldParams.configInfo;
    if isempty(cfgSettings)
        return;
    end

    validTarget=false;
    switch codingTarget
    case 'mex'
        if isa(cfgSettings,'coder.MexCodeConfig')||isa(cfgSettings,'coder.MexConfig')
            validTarget=true;
        end
    case{'rtw','rtw:lib','rtw:dll','rtw:exe'}
        if isa(cfgSettings,'coder.CodeConfig')||isa(cfgSettings,'coder.EmbeddedCodeConfig')
            validTarget=true;
        end
    otherwise
        validTarget=false;
    end
    if~validTarget
        error(message('Coder:buildProcess:unrecognizedTarget'));
    end
end


function checkArgs(bldParams)
    checkCancellationRequest(bldParams.project);
    if~isa(bldParams.project,'coder.internal.Project')
        error(message('Coder:buildProcess:expectedProjectArgument'));
    end
    if~isa(bldParams.buildInfo,'RTW.BuildInfo')
        error(message('Coder:buildProcess:expectedBuildInfoArgument'));
    end
    if~isa(bldParams.tflControl,'RTW.TflControl')
        error(message('Coder:buildProcess:expectedTflControlArgument'));
    end
end


function setup_nvtx(bldParams)

    if~isempty(bldParams.configInfo.GpuConfig)&&...
        bldParams.configInfo.GpuConfig.Enabled&&...
        bldParams.configInfo.GpuConfig.AddnvtxInstrumentation
        if~ispc
            bldParams.buildInfo.addSysLibs('nvToolsExt');
        else
            nvToolPath=getenv('NVTOOLSEXT_PATH');
            libPath=fullfile(nvToolPath,'lib','x64');
            incPath=fullfile(nvToolPath,'include');
            bldParams.buildInfo.addSysLibPaths(libPath);
            bldParams.buildInfo.addLinkFlags('nvToolsExt64_1.lib');
            bldParams.buildInfo.addIncludePaths(incPath);
        end

    end
end


