function[buildSuccess,generatedExeFullPath]=genCustomCodeExe(modelName,settingsChecksum,fullChecksum,fcnList)



    if(~ischar(modelName))
        modelName=get_param(modelName,'Name');
    end

    buildSuccess=false;
    generatedExeFullPath='';


    fcnList=fcnList(~cellfun('isempty',{fcnList.FunctionName}));


    fileGenCfg=Simulink.fileGenControl('getConfig');
    projRootDir=fileGenCfg.CacheFolder;

    expectedExeFullPath=SLCC.OOP.getCustomCodeExeExpectedFullPath(settingsChecksum,fullChecksum);
    [ccExeDir,ccExeName,~]=fileparts(expectedExeFullPath);

    if~exist(ccExeDir,'dir')
        mkdir(ccExeDir);
    end

    currDir=pwd;
    cd(ccExeDir);
    c=onCleanup(@()cd(currDir));


    customCodeSettings=CGXE.CustomCode.CustomCodeSettings.createFromModel(modelName);
    [buildNeeded,~,~]=customCodeSettings.hasCustomCode();
    if~buildNeeded
        return;
    end


    compArch=computer('arch');
    compilerInfo=cgxeprivate('compilerman','get_compiler_info',customCodeSettings.isCpp);
    compiler=compilerInfo.compilerName;
    libPathDir='';%#ok<NASGU> 
    switch(compiler)
    case cgxeprivate('supportedPCCompilers','microsoft')
        isDebuggerSupported=true;
        libPathDir=fullfile(matlabroot,'extern','lib',compArch,'microsoft');
    case 'lcc'
        isDebuggerSupported=false;
        libPathDir=fullfile(matlabroot,'extern','lib',compArch,'microsoft');
    case cgxeprivate('supportedPCCompilers','mingw')
        isDebuggerSupported=false;
        libPathDir=fullfile(matlabroot,'bin',compArch);
    case{'gcc','g++'}
        isDebuggerSupported=~ismac;
        libPathDir=fullfile(matlabroot,'bin',compArch);
    case{'clang','clang++'}
        isDebuggerSupported=ismac;
        libPathDir=fullfile(matlabroot,'bin',compArch);
    otherwise
        isDebuggerSupported=false;
        libPathDir='';
    end


    SLCC.OOP.genWrapperHeaderAndSource(modelName,customCodeSettings,settingsChecksum,fcnList,isDebuggerSupported);


    cgxeprivate('code_rtwtypesdoth',modelName,pwd);


    loc_createDummyRtwProjFileIfNotExist('.');


    assert(~rtw.connectivity.Utils.isCommServiceAPIEnabled,'XIL CommServiceAPI must be disabled for SLOOP feature!');
    compArgs=coder.connectivity.ComponentArgs(modelName,ccExeDir,ccExeName,ccExeDir);
    compArgs.CoderAssumptionsEnabled=false;
    compArgs.CoderAssumptionsDAZCheckEnabled=false;
    cs=getActiveConfigSet(modelName);
    internalData.configInterface=coder.connectivity.SimulinkConfig(cs,modelName);
    compArgs.setInternalData(internalData);

    isSILAndPWS=false;
    if customCodeSettings.isCpp



        comp=mex.getCompilerConfigurations('C++','selected');
        [compStr,~]=cgxeprivate('hCreateCompStr',comp);
        defaultMexCompInfo.DefaultMexCompInfo=coder.make.internal.getMexCompInfoFromKey(compStr);
        if~isempty(defaultMexCompInfo.DefaultMexCompInfo)
            mexCompilerKey=compStr;
            tcName=coder.make.internal.getToolchainNameFromRegistry(mexCompilerKey);
            defaultMexCompInfo.ToolchainInfo=coder.make.internal.getToolchainInfoFromRegistry(tcName);
            defaultMexCompInfo.DefaultMexCompilerKey=mexCompilerKey;
        end
    else
        defaultMexCompInfo=coder.internal.DefaultCompInfo.createDefaultCompInfo;
    end
    xilCompInfo=coder.internal.utils.XilCompInfo.slCreateXilCompInfo...
    (cs,defaultMexCompInfo,isSILAndPWS);
    compArgs.setXilCompInfo(xilCompInfo);

    targetApplicationFramework=rtw.pil.HostDemoApplicationFramework(compArgs);
    buildInfo=targetApplicationFramework.getBuildInfo;
    rtw.pil.BuildInfoHelpers.addTargetSendAndReceiveBufferSizeDefines(buildInfo,...
    targetApplicationFramework.getTargetRecvBufferSizeBytes(),...
    targetApplicationFramework.getTargetSendBufferSizeBytes());


    buildInfo.ModelName=modelName;
    buildInfo.ModelHandle=get_param(modelName,'handle');



    keepIdx=true(size(buildInfo.Src.Files));
    for idx=1:length(buildInfo.Src.Files)
        srcFileName=buildInfo.Src.Files(idx).FileName;
        if strcmp(srcFileName,'xil_interface.c')||strcmp(srcFileName,'xil_interface.cpp')
            keepIdx(idx)=false;
            break;
        end
    end
    buildInfo.Src.Files=buildInfo.Src.Files(keepIdx);


    buildInfo.setStartDir(projRootDir);


    buildInfo.setOutputFolder('.');


    buildInfo.addIncludePaths(fullfile(matlabroot,'simulink','include'));



    targetLangExt='c';
    if customCodeSettings.isCpp
        targetLangExt='cpp';
    end
    buildInfo.addSourceFiles([settingsChecksum,'_interface.',targetLangExt],ccExeDir);


    signalHandlerDefineName='XIL_SIGNAL_HANDLER';
    buildInfo.addDefines([signalHandlerDefineName,'=1'],'OPTS');


    buildInfo.addDefines('OUT_OF_PROCESS_EXEC=1','OPTS');
    buildInfo.addDefines('MEM_UNIT_BYTES=1','OPTS');
    buildInfo.addDefines('MemUnit_T=uint8_T','OPTS');
    buildInfo.addDefines('MATLAB_MEX_FILE','OPTS');


    buildInfo.addBuildArgs('MAKEFILEBUILDER_TGT','1');
    buildInfo.addBuildArgs('MODELREF_TARGET_TYPE','NONE','BUILD_ARG');
    buildInfo.addBuildArgs('RELATIVE_PATH_TO_ANCHOR',fullfile('..','..','..'),'makevar_BUILD_ARG_PATH');
    buildInfo.addTMFTokens('|>MODEL_NAME<|',modelName,'');
    buildInfo.addTMFTokens('|>TARGET_LANG_EXT<|',targetLangExt,'');



    buildInfo.addTMFTokens('|>TGT_FCN_LIB<|','ISO_C','makevar');


    compilerName=defaultMexCompInfo.ToolchainInfo.Alias;
    if~isempty(regexpi(compilerName,'gnu','once'))&&isunix

        buildInfo.addLinkFlags('-rdynamic');
    end


    if~isempty(libPathDir)
        if strcmp(compArch,'glnxa64')

            sysOSArch=fullfile(matlabroot,'sys','os',compArch,'orig',filesep);
            buildInfo.addLinkObjects('libstdc++.so.6',sysOSArch,[],true,true);
        end
        addSysLibs(buildInfo,'mx',libPathDir);
        addSysLibs(buildInfo,'mex',libPathDir);
    end


    if~isempty(customCodeSettings.customUserDefines)
        buildInfo.addDefines(CGXE.CustomCode.extractUserDefines(customCodeSettings.customUserDefines));
    end
    if~isempty(customCodeSettings.customCompilerFlags)
        buildInfo.addCompileFlags(customCodeSettings.customCompilerFlags);
    end
    if~isempty(customCodeSettings.customLinkerFlags)
        buildInfo.addLinkFlags(customCodeSettings.customLinkerFlags);
    end
    [userIncludeDirs,userSources,userLibraries]=cgxeprivate('getTokenizedPathsAndFiles',modelName,projRootDir,customCodeSettings,ccExeDir);
    buildInfo.addIncludePaths(userIncludeDirs);
    buildInfo.addSourceFiles(userSources);
    allLibraries=cgxeprivate('addMissingPartnerLibraries',userLibraries);
    [runtimeLibraries,linkLibraries]=cgxeprivate('getLinkAndRuntimeLibs',allLibraries);
    [linkLibPaths,linkLibNames,linkLibExts]=cellfun(@fileparts,linkLibraries,'UniformOutput',false);
    buildInfo.addLinkObjects(strcat(linkLibNames,linkLibExts),linkLibPaths,[],true,true);

    if(~cgxe('Feature','SetEnvDuringLoadDLL'))

        cgxeprivate('generateLinksForCustomCodeLibraries',ccExeDir,runtimeLibraries);
    end



    try
        buildInfo.ComponentBuildFolder=ccExeDir;
        codebuild(buildInfo,...
        'BuildMethod',defaultMexCompInfo.ToolchainInfo.Name,...
        'BuildConfiguration','Debug',...
        'TargetLangExt',targetLangExt,...
        'BuildVariant',coder.make.enum.BuildVariant.STANDALONE_EXECUTABLE,...
        'makefileName',[settingsChecksum,'.mk'],...
        'BuildName',fullChecksum);
    catch ME
        exception=MException(message('Simulink:CustomCode:OOPExeBuildFailure',modelName));
        makeException=addCause(exception,ME);
        throw(makeException);
    end



    if exist(expectedExeFullPath,'file')==2
        buildSuccess=true;
        generatedExeFullPath=expectedExeFullPath;
    end


end



function loc_createDummyRtwProjFileIfNotExist(buildFolder)

    rtwProjFile=fullfile(buildFolder,'rtw_proj.tmw');
    if~exist(rtwProjFile,'file')
        fid=fopen(rtwProjFile,'w');
        fprintf(fid,'This file is generated by SLOOP.');
        fclose(fid);
    end
end