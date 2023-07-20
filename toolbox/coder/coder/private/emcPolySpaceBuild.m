function buildResults=emcPolySpaceBuild(bldParams)




    project=bldParams.project;
    buildInfo=bldParams.buildInfo;
    configInfo=bldParams.configInfo;
    isClassAsEntrypoint=project.getIsClassAsEntrypoint();
    bldParams.canWriteCodeDescriptor=emcCanWriteCodeDescriptor(bldParams);
    tflControl=[];

    if isfield(bldParams,'tflControl')
        tflControl=bldParms.tflControl;
    end

    if bldParams.canWriteCodeDescriptor
        configInterface=coder.connectivity.MATLABConfig(bldParams.configInfo,...
        bldParams.project.Name);
        coder.assumptions.CoderAssumptions.serializeCoderAssumptionsToCodeDescriptor(...
        configInterface,bldParams.project.BldDirectory);
    else
        bldParams=emcCantWriteCodeDescriptorWarning(bldParams);
    end
    bldParams=emcSaveBuildInfo(bldParams);%#ok<NASGU>

    projName=GetTokenValue(buildInfo,'EMC_PROJECT');
    if isempty(projName)
        projName='Untitled';
    end

    coder.connectivity.MATLABSILPIL.emcIsXILEnabled(configInfo,project);

    tmfToks=[];
    lMexCompilerKey='';
    tmfName='';
    [compilerName,compilerInfo,toolchainInfo]=getCompilerNameFromToolchainInfo(configInfo);
    if toolchainInfo.SupportsBuildingMEXFuncs
        lMexCompilerKey=toolchainInfo.Alias{1};
    end
    lToolchainOrTMF=toolchainInfo;

    rtwPreBuild(project,configInfo,buildInfo,tflControl,lMexCompilerKey);

    buildOpts=coder.make.BuildOpts;
    buildOpts.BuildName=[projName,'_rtw'];
    buildOpts.makefileName=[projName,'_rtw.mk'];

    if isprop(configInfo,'TargetLang')
        buildOpts.TargetLang=configInfo.TargetLang;
        if configInfo.TargetLang=="C++"

            buildOpts.isCpp=true;
        end
    else
        buildOpts.TargetLang='C';
    end

    coder.connectivity.MATLABSILPIL.clearSILAndPILApplications(project);

    argGroup='BUILD_ARG';
    codingTarget=lower(project.CodingTarget);
    targetName=GetTokenValue(buildInfo,'MLC_TARGET_NAME','BuildArgs');

    switch codingTarget
    case 'rtw:dll'
        tc=toolchainInfo.getBuildTool('Linker');
        mdlLibSuffix=tc.getFileExtension('Shared Library');
    otherwise
        tc=toolchainInfo.getBuildTool('Archiver');
        mdlLibSuffix=tc.getFileExtension('Static Library');
    end

    modelLibName=[targetName,mdlLibSuffix];
    emcRemoveFile(project.BldDirectory,modelLibName);

    buildOpts.isMATLABCodeGen=1;
    buildOpts.BuildName=targetName;
    buildInfo.ModelName=projName;

    if contains(toolchainInfo.Name,'MinGW')
        buildInfo.addDefines('-D__USE_MINGW_ANSI_STDIO=1');
    end


    if project.FeatureControl.EMLParallelCodeGen
        buildInfo.setCompilerRequirements('supportOpenMP',true);
    end

    tmfToks=[tmfToks,locNewTok('|>MAKEFILE_NAME<|',buildOpts.makefileName)];
    tmfToks=[tmfToks,locNewTok('|>COMPUTER<|',computer())];
    tmfToks=[tmfToks,locNewTok('|>MEXEXT<|',mexext())];

    if~isempty(tflControl)
        tmfToks=[tmfToks,locNewTok('|>TGT_FCN_LIB<|',...
        RTW.resolveTflName(configInfo.CodeReplacementLibrary,'ForMakeFile',true,'TargetLangStdTfl',tflControl.TargetLangStdTfl),...
        'makevar')];
    end

    buildInfo.addTMFTokens({tmfToks(:).token},{tmfToks(:).value},{tmfToks(:).group});

    toolchainOrTemplateDesc=['toolchain "',toolchainInfo.Name,'"'];

    genTMWFile(buildInfo,toolchainOrTemplateDesc,projName,coder.internal.BuildMode.Normal);

    if compilerInfo.codingMicrosoftMakefile||compilerInfo.codingIntelMakefile


        [file,fspec]=OpenSupportFile(buildInfo,[projName,'.def'],bldMode);
        buildInfo.addNonBuildFiles(fspec);
        fclose(file);
    elseif compilerInfo.codingUnixMakefile
        buildInfo.addCompileFlags('-fvisibility=hidden');
    end
    buildInfo.addDefines(['BUILDING_',upper(project.Name)]);

    targetType=codingTarget;


    lBuildVariant=coder.internal.getDataForBuildToolInfoML(codingTarget);
    buildOpts.BuildVariant=lBuildVariant;


    if~isempty(toolchainInfo)
        addBuildArgs(buildInfo,'DEFAULT_TOOLCHAIN_FOR_PACKNGO',...
        toolchainInfo.Name,argGroup);
        addBuildArgs(buildInfo,'DEFAULT_BUILD_VARIANT_FOR_PACKNGO',...
        char(lBuildVariant),argGroup);
    end

    buildInfo.addBuildArgs('MODELREF_TARGET_TYPE',targetType,argGroup);

    use_RT_MALLOC=false;
    addStandardInfoForML(buildInfo,buildOpts.isCpp,use_RT_MALLOC,targetName,configInfo);


    switch codingTarget
    case 'rtw:dll'
        toolchainExtension=...
        toolchainInfo.getBuildTool('Linker').getFileExtension('Shared Library');
    case 'rtw:lib'
        toolchainExtension=...
        toolchainInfo.getBuildTool('Archiver').getFileExtension('Static Library');
    end
    modelLibName=[targetName,toolchainExtension];

    buildInfo.addBuildArgs('MODELLIB',modelLibName,argGroup);



    rootFolder=emcGetBuildDirectory(buildInfo,coder.internal.BuildMode.Normal);





    componentBuildDir=emcGetBuildDirectory(buildInfo,coder.internal.BuildMode.Normal);


    locSetBuildInfoFolders(buildInfo,rootFolder,project.OutDirectory,componentBuildDir)

    saveBuildInfo(buildInfo,buildOpts,coder.internal.BuildMode.Normal);
    emcRunPostCodeGenCommand(project,buildInfo,configInfo);


    [allModules,buildInfoPrunedSrcFiles]=getModuleList...
    (buildInfo,coder.internal.BuildMode.Normal,codingTarget,configInfo.GenerateExampleMain,isClassAsEntrypoint);

    modelModulesObj=getObjectFiles(allModules,toolchainInfo);
    emcRemoveFile(project.BldDirectory,setdiff(modelModulesObj,allModules));

    lIsSILDebuggingEnabled=isSILDebuggingEnabled(configInfo,project,true);


    checkCompilerCompatible(compilerName,configInfo);

    lIsXILFcnProfilingEnabled=isXILFcnProfilingEnabled(configInfo,project,true);
    lIsXILCodeCoverageEnabled=isXILCodeCoverageEnabled(configInfo,project,true);

    if lIsXILFcnProfilingEnabled

        coder.connectivity.MATLABSILPIL.checkOpenMPCodandFunctionProfiling(...
        project,buildInfo.Settings.CompilerRequirements.supportOpenMP);
    end

    if lIsXILFcnProfilingEnabled||lIsXILCodeCoverageEnabled

        lTraceInfo='traceInfo';
        [instrBuildInfo,instrDir]=...
        coder.connectivity.doCloneAndInstrumentation(project,buildInfo,...
        isCpp,configInfo,tmfName,lTraceInfo,...
        lBuildVariant,toolchainInfo);

        modelModulesObj{end+1}=modelLibName;
        emcRemoveFile(instrDir,setdiff(modelModulesObj,allModules));
        [~,instrBuildInfoPrunedSrcFiles]=getModuleList(instrBuildInfo,...
        bldMode,codingTarget,configInfo.GenerateExampleMain,isClassAsEntrypoint);


        buildInfoForCompilation=instrBuildInfo;
        buildInfoPrunedSrcFilesForCompilation=instrBuildInfoPrunedSrcFiles;
    else

        buildInfoForCompilation=buildInfo;
        buildInfoPrunedSrcFilesForCompilation=buildInfoPrunedSrcFiles;
    end



    buildResults=locGenMakefileAndBuild...
    (buildInfoForCompilation,lToolchainOrTMF,buildOpts,...
    buildInfoPrunedSrcFilesForCompilation,...
    lIsSILDebuggingEnabled,...
    configInfo.BuildConfiguration,...
    configInfo.CustomToolchainOptions);


    if~buildResults.success
        return;
    end


    if lIsXILFcnProfilingEnabled||lIsXILCodeCoverageEnabled





        if isfile(fullfile(instrDir,modelLibName))


            copyfile(fullfile(instrDir,modelLibName),...
            fullfile(instrBuildInfo.Settings.LocalAnchorDir,modelLibName));
        end
    end




    coder.connectivity.MATLABSILPIL.RTWBuildHook(configInfo,project);

    if~configInfo.GenCodeOnly&&isprop(configInfo,'Hardware')&&~isempty(configInfo.Hardware)
        configInfo.Hardware.postBuild(configInfo,buildInfo);
    end
end


function saveBuildInfo(buildInfo,buildOpts,bldMode)
    try
        buildDir=emcGetBuildDirectory(buildInfo,bldMode);
        buildInfo.ComponentBuildFolder=buildDir;
        coder.make.internal.saveBuildArtifacts(buildInfo,buildOpts);
    catch
    end
end


function locSetBuildInfoFolders...
    (buildInfo,rootFolder,projectOutputFolder,componentBuildDir)


    setRootFolder(buildInfo,rootFolder)

    buildInfo.ComponentBuildFolder=componentBuildDir;


    setOutputFolder(buildInfo,projectOutputFolder);
end


function checkCompilerCompatible(compilerName,configInfo)
    if~strcmp(configInfo.TargetLang,'C')
        if strcmpi(compilerName,'lcc64')
            error(message('Coder:configSet:lccNotCPPcompiler'));
        elseif strcmpi(compilerName,'watc')
            if strcmpi(configInfo.OutputType,'DLL')
                error(message('Coder:configSet:watcomNotCPPDLLcompiler'));
            end
        end
    end
end


function locRestoreBuildInfoSrcFiles(buildInfo,buildInfoSrcFiles)
    buildInfo.Src.Files=buildInfoSrcFiles;
end


function buildResults=locGenMakefileAndBuild(buildInfo,lToolchainOrTMF,buildOpts,...
    buildInfoPrunedSrcFiles,lIsSILDebuggingEnabled,...
    lBuildConfiguration,lCustomToolchainOptions)

    if lIsSILDebuggingEnabled

        [lBuildConfiguration,lCustomToolchainOptions]=...
        coder.internal.overrideBuildConfigAndOptionsForDebug...
        (lToolchainOrTMF,lBuildConfiguration,lCustomToolchainOptions,buildInfo);
    end



    allBuildInfoSrcFiles=buildInfo.Src.Files;
    buildInfo.Src.Files=buildInfoPrunedSrcFiles;
    restoreBuildInfoSrcFiles=onCleanup(@()locRestoreBuildInfoSrcFiles(...
    buildInfo,allBuildInfoSrcFiles));

    buildOpts.ComponentsToBuild=buildInfo.ComponentName;
    buildOpts.BuildMethod=lToolchainOrTMF;
    buildOpts.BuildConfiguration=lBuildConfiguration;
    buildOpts.CustomToolchainOptions=lCustomToolchainOptions;




    coder.make.internal.saveBuildArtifacts(buildInfo,buildOpts);

    buildResults=coder.internal.MakeResult;
    function callMake(buildResults)
        try
            lMakeResult=codebuild(buildInfo,buildOpts);

            buildResults.propagateFromBTIMakeResult(lMakeResult);
            if buildOpts.generateCodeOnly
                buildResults.Log=message('Coder:buildProcess:compilationSuppressed').getString;
                buildResults.isBuildOnly=true;
            end
            buildResults.success=true;
        catch err
            log=err.message;
            log=regexprep(log,'^[^\n]*==>[^\n]*\n','','once');
            log=regexprep(log,'Error\(s\) encountered while building model[^\n]*\n*$','','once');
            buildResults.Log=log;
            buildResults.message=...
            message('Coder:buildProcess:compilationErrorStatus',buildOpts.TargetLang).getString;
        end
    end
    cmdOut=evalc('callMake(buildResults)');
    buildResults.Log=sprintf('%s%s',cmdOut,buildResults.Log);
end


function[sources,buildInfoPrunedSrcFiles]=getModuleList...
    (buildInfo,bldMode,codingTarget,lGenerateExampleMain,isClassAsEntrypoint)




    concatenatePaths=false;
    replaceMatlabroot=true;
    switch bldMode
    case coder.internal.BuildMode.Normal
        includeGroups='';
        if~isClassAsEntrypoint&&...
            strcmp(lGenerateExampleMain,'GenerateCodeAndCompile')&&...
            strcmp(codingTarget,'rtw:exe')
            excludeGroups={};
        else
            excludeGroups={'Examples','Target'};
        end
    case coder.internal.BuildMode.Example
        includeGroups={'Examples'};
        excludeGroups='';
    end
    sources=buildInfo.getSourceFiles(concatenatePaths,replaceMatlabroot,includeGroups,excludeGroups);


    keepIdx=true(size(buildInfo.Src.Files));
    for i=1:numel(keepIdx)
        group=buildInfo.Src.Files(i).Group;
        if~isempty(includeGroups)&&~ismember(group,includeGroups)
            keepIdx(i)=false;
        end
        if ismember(group,excludeGroups)
            keepIdx(i)=false;
        end
    end
    buildInfoPrunedSrcFiles=buildInfo.Src.Files(keepIdx);
end


function tok=locNewTok(new_tok,new_val,varargin)
    if(nargin==3)
        group=varargin{1};
    else
        group='';
    end
    tok.token=new_tok;
    tok.value=new_val;
    tok.group=group;
end


function lIsSILDebuggingEnabled=isSILDebuggingEnabled(configInfo,project,isXILEnabled)

    if isXILEnabled&&isprop(configInfo,'VerificationMode')
        allEntryPoints=project.EntryPoints;
        configInterface=coder.connectivity.MATLABConfig(configInfo,allEntryPoints(1).Name);
        lIsSILDebuggingEnabled=strcmp(configInterface.getParam('SILDebugging'),'on')...
        &&~strcmp(configInfo.BuildConfiguration,'Debug');
    else
        lIsSILDebuggingEnabled=false;
    end
end


function lProfilingEnabled=isXILFcnProfilingEnabled(configInfo,project,isXILEnabled)

    if isXILEnabled&&isprop(configInfo,'VerificationMode')
        allEntryPoints=project.EntryPoints;
        configInterface=coder.connectivity.MATLABConfig(configInfo,allEntryPoints(1).Name);
        lProfilingEnabled=strcmp(configInterface.getParam('CodeExecutionProfiling'),'on')&&...
        strcmp(configInterface.getParam('CodeProfilingInstrumentation'),'on');
    else
        lProfilingEnabled=false;
    end
end


function lCodeCovEnabled=isXILCodeCoverageEnabled(configInfo,~,isXILEnabled)

    lCodeCovEnabled=isXILEnabled&&isprop(configInfo,'VerificationMode')&&...
    coder.internal.connectivity.featureOn('MLCodeCoverage');
end

