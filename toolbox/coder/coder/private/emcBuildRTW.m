function buildResults=emcBuildRTW(bldParams,bldMode)





    project=bldParams.project;
    buildInfo=bldParams.buildInfo;
    configInfo=bldParams.configInfo;
    tflControl=bldParams.tflControl;

    projName=GetTokenValue(buildInfo,'EMC_PROJECT');
    if isempty(projName)
        projName='Untitled';
    end

    isXILEnabled=...
    coder.connectivity.MATLABSILPIL.emcIsXILEnabled(configInfo,project);

    tmfToks=[];
    lMexCompilerKey='';
    [compilerName,compilerInfo,toolchainInfo]=getCompilerNameFromToolchainInfo(configInfo);
    if toolchainInfo.SupportsBuildingMEXFuncs
        lMexCompilerKey=toolchainInfo.Alias{1};
    end
    lToolchainOrTMF=toolchainInfo;

    rtwPreBuild(project,configInfo,buildInfo,tflControl,lMexCompilerKey);

    buildOpts=coder.make.BuildOpts;

    switch bldMode
    case coder.internal.BuildMode.Normal
        buildOpts.BuildName=[projName,'_rtw'];
        buildOpts.makefileName=[projName,'_rtw.mk'];
    case coder.internal.BuildMode.Example
        buildOpts.BuildName=[projName,'_rtw_example'];
        buildOpts.makefileName=[projName,'_rtw_example.mk'];
    end

    if isprop(configInfo,'TargetLang')
        buildOpts.TargetLang=configInfo.TargetLang;
    else
        buildOpts.TargetLang='C';
    end

    buildOpts.generateCodeOnly=configInfo.GenCodeOnly;

    if bldMode==coder.internal.BuildMode.Normal

        coder.connectivity.MATLABSILPIL.clearSILAndPILApplications(project);
    end

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

    if~strcmp(codingTarget,'rtw:exe')
        switch bldMode
        case coder.internal.BuildMode.Normal
            emcRemoveFile(project.BldDirectory,modelLibName);
        case{coder.internal.BuildMode.Example}
            if ispc&&strcmp(codingTarget,'rtw:dll')&&strcmp(mdlLibSuffix,'.dll')
                modelLibName=strrep(modelLibName,'.dll','.lib');
            end
            buildInfo.addLinkObjects(modelLibName,project.BldDirectory,0,1,1,'CustomCode');
        end
    end

    buildOpts.isMATLABCodeGen=1;
    buildOpts.BuildName=targetName;
    buildInfo.ModelName=projName;
    switch bldMode
    case coder.internal.BuildMode.Normal
        if strcmp(configInfo.GenerateExampleMain,'GenerateCodeAndCompile')&&...
            strcmp(codingTarget,'rtw:exe')
        end

    case coder.internal.BuildMode.Example
        if strcmp(codingTarget,'rtw:dll')||strcmp(codingTarget,'rtw:lib')
            codingTarget='rtw:exe';
        end
    end
    isCpp=strcmp(configInfo.TargetLang,'C++');

    buildOpts.isCpp=isCpp;

    if contains(toolchainInfo.Name,'MinGW')
        buildInfo.addDefines('-D__USE_MINGW_ANSI_STDIO=1');
    end


    if project.FeatureControl.EMLParallelCodeGen
        buildInfo.setCompilerRequirements('supportOpenMP',true);
    end

    tmfToks=[tmfToks,locNewTok('|>MAKEFILE_NAME<|',buildOpts.makefileName)];
    tmfToks=[tmfToks,locNewTok('|>COMPUTER<|',computer())];
    tmfToks=[tmfToks,locNewTok('|>MEXEXT<|',mexext())];
    tmfToks=[tmfToks,locNewTok('|>TGT_FCN_LIB<|',...
    RTW.resolveTflName(configInfo.CodeReplacementLibrary,'ForMakeFile',true,'TargetLangStdTfl',tflControl.TargetLangStdTfl),...
    'makevar')];

    buildInfo.addTMFTokens({tmfToks(:).token},{tmfToks(:).value},{tmfToks(:).group});

    if isempty(toolchainInfo)
        toolchainOrTemplateDesc=['"',compilerName,'"'];
    else
        toolchainOrTemplateDesc=['toolchain "',toolchainInfo.Name,'"'];
    end

    genTMWFile(buildInfo,toolchainOrTemplateDesc,projName,bldMode);


    if project.FeatureControl.FileSaveEncoding=="UTF-8"
        if compilerInfo.codingMicrosoftMakefile&&compilerName=="vcx64"
            flag='/source-charset:utf-8';
            if~isempty(bldParams.configInfo.GpuConfig)&&...
                bldParams.configInfo.GpuConfig.Enabled
                flag=['-Xcompiler "',flag,'"'];
            end
            buildInfo.addCompileFlags(flag);
        elseif compilerInfo.codingIntelMakefile&&compilerName=="intelvcx64"
            buildInfo.addCompileFlags('-Qoption,cpp,--unicode_source_kind,"UTF-8"');
        end
    end

    switch bldParams.project.FeatureControl.ExportStyle
    case "File"

        if compilerInfo.codingUnixMakefile&&ispc&&~coder.make.internal.buildMethodIsCMake(toolchainInfo)
            buildInfo.addLinkFlags('$(DEF_FILE)');
        end
        gen_linkfile(buildInfo,projName,compilerInfo,bldMode);
    case "Macro"
        if compilerInfo.codingMicrosoftMakefile||compilerInfo.codingIntelMakefile


            [file,fspec]=OpenSupportFile(buildInfo,[projName,'.def'],bldMode);
            if bldMode==coder.internal.BuildMode.Normal
                buildInfo.addNonBuildFiles(fspec);
            end
            fclose(file);
        elseif compilerInfo.codingUnixMakefile
            if~isempty(toolchainInfo)&&...
                strcmp(toolchainInfo.getBuildTool('C Compiler').getCommand(),'nvcc')
                buildInfo.addCompileFlags('-Xcompiler -fvisibility=hidden');
            else
                buildInfo.addCompileFlags('-fvisibility=hidden');
            end
        end
        buildInfo.addDefines(['BUILDING_',upper(bldParams.project.Name)]);
    end

    targetType='NONE';
    switch codingTarget
    case 'rtw:exe'
    otherwise
        switch bldMode
        case coder.internal.BuildMode.Normal
            targetType=codingTarget;
        end
    end


    lBuildVariant=coder.internal.getDataForBuildToolInfoML(codingTarget);
    buildOpts.BuildVariant=lBuildVariant;



    if~strcmp(codingTarget,'rtw:dll')
        buildInfo.DisallowedBuildVariants='SHARED_LIBRARY';
    end


    if~isempty(toolchainInfo)
        addBuildArgs(buildInfo,'DEFAULT_TOOLCHAIN_FOR_PACKNGO',...
        toolchainInfo.Name,argGroup);
        addBuildArgs(buildInfo,'DEFAULT_BUILD_VARIANT_FOR_PACKNGO',...
        char(lBuildVariant),argGroup);
    end

    buildInfo.addBuildArgs('MODELREF_TARGET_TYPE',targetType,argGroup);

    use_RT_MALLOC=false;
    addStandardInfoForML(buildInfo,isCpp,use_RT_MALLOC,targetName,configInfo);


    switch codingTarget
    case 'rtw:dll'
        toolchainExtension=...
        toolchainInfo.getBuildTool('Linker').getFileExtension('Shared Library');
    case 'rtw:lib'
        toolchainExtension=...
        toolchainInfo.getBuildTool('Archiver').getFileExtension('Static Library');
    otherwise
        toolchainExtension=mdlLibSuffix;
    end
    modelLibName=[targetName,toolchainExtension];

    buildInfo.addBuildArgs('MODELLIB',modelLibName,argGroup);



    rootFolder=emcGetBuildDirectory(buildInfo,coder.internal.BuildMode.Normal);





    componentBuildDir=emcGetBuildDirectory(buildInfo,bldMode);


    locSetBuildInfoFolders(buildInfo,rootFolder,project.OutDirectory,...
    componentBuildDir,bldParams.project.IsUserSpecifiedOutputDir);

    if bldMode==coder.internal.BuildMode.Normal
        saveBuildInfo(buildInfo,buildOpts,bldMode);
        emcRunPostCodeGenCommand(project,buildInfo,configInfo);
    end


    [allModules,buildInfoPrunedSrcFiles]=getModuleList...
    (buildInfo,bldMode,codingTarget,configInfo.GenerateExampleMain);

    modelModulesObj=getObjectFiles(allModules,toolchainInfo);
    emcRemoveFile(project.BldDirectory,setdiff(modelModulesObj,allModules));

    lIsSILDebuggingEnabled=isSILDebuggingEnabled(configInfo,project,isXILEnabled);


    if~configInfo.GenerateMakefile
        saveBuildInfo(buildInfo,buildOpts,bldMode);
        buildResults=coder.internal.MakeResult();
        buildResults.success=true;
        return;
    end

    checkCompilerCompatible(compilerName,configInfo);

    lIsXILFcnProfilingEnabled=isXILFcnProfilingEnabled(configInfo,project,isXILEnabled);
    lIsXILCodeCoverageEnabled=isXILCodeCoverageEnabled(configInfo,project,isXILEnabled);
    lIsPSTestInstrumentationEnabled=isPSTestInstrumentationEnabled(configInfo,project,isXILEnabled);
    lIsStackProfilingEnabled=isStackProfilingEnabled(configInfo,project,isXILEnabled);

    if lIsXILFcnProfilingEnabled

        coder.connectivity.MATLABSILPIL.checkOpenMPCodandFunctionProfiling(...
        project,buildInfo.CompilerRequirements.supportOpenMP);
    end
    if lIsStackProfilingEnabled

        coder.connectivity.MATLABSILPIL.checkOpenMPCodandStackProfiling(...
        project,buildInfo.CompilerRequirements.supportOpenMP);
    end

    if lIsXILFcnProfilingEnabled||lIsXILCodeCoverageEnabled||...
        lIsPSTestInstrumentationEnabled||lIsStackProfilingEnabled

        lTraceInfo='traceInfo';
        [instrBuildInfo,instrDir]=...
        coder.connectivity.doCloneAndInstrumentation(project,buildInfo,...
        configInfo,toolchainInfo,lTraceInfo,...
        lBuildVariant);

        modelModulesObj{end+1}=modelLibName;
        emcRemoveFile(instrDir,setdiff(modelModulesObj,allModules));
        [~,instrBuildInfoPrunedSrcFiles]=getModuleList(instrBuildInfo,...
        bldMode,codingTarget,configInfo.GenerateExampleMain);


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


    if lIsXILFcnProfilingEnabled||lIsXILCodeCoverageEnabled||...
        lIsPSTestInstrumentationEnabled||lIsStackProfilingEnabled





        if isfile(fullfile(instrDir,modelLibName))


            copyfile(fullfile(instrDir,modelLibName),...
            fullfile(project.BldDirectory,modelLibName));
        end
    end



    if isXILEnabled&&bldMode==coder.internal.BuildMode.Normal

        coder.connectivity.MATLABSILPIL.RTWBuildHook(configInfo,project);
    end
    if~configInfo.GenCodeOnly&&isprop(configInfo,'Hardware')&&~isempty(configInfo.Hardware)
        configInfo.Hardware.postBuild(configInfo,buildInfo);
    end


    if project.FeatureControl.ROSNodeGeneration==1
        rosNodeCMakeListGeneration(buildInfo,bldParams);
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


function locSetBuildInfoFolders(buildInfo,rootFolder,projectOutputFolder,...
    componentBuildDir,isUserSpecifiedOutputDir)
    if isUserSpecifiedOutputDir


        setRootFolder(buildInfo,rootFolder);
    else



        setRootFolder(buildInfo,fileparts(fileparts(fileparts(rootFolder))));
    end

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


function gen_linkfile(buildInfo,projName,compilerInfo,bldMode)
    function unix_emitter
        if bldMode==coder.internal.BuildMode.Normal
            fprintf(file,'DLL {\n');
            fprintf(file,'\tglobal:\n');
            for i=1:numel(entry_points)
                fprintf(file,'\t\t%s;\n',entry_points{i});
            end
            fprintf(file,'\tlocal:\n');
            fprintf(file,'\t\t*;\n');
            fprintf(file,'};\n');
        end
    end

    function mac_emitter
        if bldMode==coder.internal.BuildMode.Normal
            for i=1:numel(entry_points)
                fprintf(file,'_%s\n',entry_points{i});
            end
        end
    end

    function microsoft_lcc64_emitter
        if bldMode==coder.internal.BuildMode.Normal
            fprintf(file,'EXPORTS\n');
            for i=1:numel(entry_points)
                fprintf(file,'%s\n',entry_points{i});
            end
        end
    end

    if compilerInfo.codingMicrosoftMakefile||compilerInfo.codingIntelMakefile
        nameSuffix='.def';
        emitter=@microsoft_lcc64_emitter;
    elseif compilerInfo.codingLcc64Makefile
        nameSuffix='.def';
        emitter=@microsoft_lcc64_emitter;
    elseif compilerInfo.codingUnixMakefile
        nameSuffix='.def';
        if ismac
            emitter=@mac_emitter;
        elseif ispc
            emitter=@microsoft_lcc64_emitter;
        else
            emitter=@unix_emitter;
        end
    else
        return;
    end

    entry_points=GetTokenValue(buildInfo,'EMC_ENTRY_POINTS');
    entry_points=textscan(entry_points,'%s','delimiter',',');
    entry_points=entry_points{1};

    [file,fspec]=OpenSupportFile(buildInfo,[projName,nameSuffix],bldMode);
    if bldMode==coder.internal.BuildMode.Normal
        buildInfo.addNonBuildFiles(fspec);
    end
    emitter();
    fclose(file);
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

    buildOpts.ComponentsToBuild={buildInfo.ComponentName};
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
    (buildInfo,bldMode,codingTarget,lGenerateExampleMain)
    concatenatePaths=false;
    replaceMatlabroot=true;
    switch bldMode
    case coder.internal.BuildMode.Normal
        includeGroups='';
        if strcmp(lGenerateExampleMain,'GenerateCodeAndCompile')&&...
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


function gen_tmwfile(buildInfo,toolchainOrTemplateDesc,projName,bldMode)
    switch bldMode
    case coder.internal.BuildMode.Normal
        tmwfile='rtw_proj.tmw';
    case coder.internal.BuildMode.Example
        tmwfile='rtw_proj_example.tmw';
    end
    [file,fspec]=OpenSupportFile(buildInfo,tmwfile,bldMode,'');
    if bldMode==coder.internal.BuildMode.Normal
        buildInfo.addNonBuildFiles(fspec);
    end
    fprintf(file,'Code generation project for %s using %s. MATLAB root = %s.\n',...
    projName,toolchainOrTemplateDesc,matlabroot);
    fclose(file);
end


function gen_rspfile(buildInfo,projName,bldMode)
    switch bldMode
    case coder.internal.BuildMode.Normal
        rspfile=[projName,'_ref.rsp'];
    case coder.internal.BuildMode.Example
        rspfile=[projName,'_ref_example.rsp'];
    end
    file=OpenSupportFile(buildInfo,rspfile,bldMode);
    fclose(file);
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


function lPSTestInstrumentationEnabled=isPSTestInstrumentationEnabled(~,project,isXILEnabled)
    if isXILEnabled
        lPSTestInstrumentationEnabled=coder.internal.connectivity.featureOn('PSTestCodeInstrumentation')&&...
        polyspace.internal.pstunit.AppBuilder.isPSTestInstrumentationNeeded(project.Name);
    else
        lPSTestInstrumentationEnabled=false;
    end
end


function lIsStackProfilingEnabled=isStackProfilingEnabled(configInfo,project,isXILEnabled)
    if isXILEnabled&&coder.profile.private.stackProfiling()&&isprop(configInfo,'VerificationMode')
        allEntryPoints=project.EntryPoints;
        configInterface=coder.connectivity.MATLABConfig(configInfo,allEntryPoints(1).Name);
        lIsStackProfilingEnabled=strcmp(configInterface.getParam('CodeStackProfiling'),'on');
    else
        lIsStackProfilingEnabled=false;
    end
end









