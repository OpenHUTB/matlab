function buildResults=emcBuildMEX(bldParams,bldMode)






    project=bldParams.project;
    buildInfo=bldParams.buildInfo.copy;
    switch bldMode
    case coder.internal.BuildMode.Normal
        configInfo=bldParams.configInfo;
    case coder.internal.BuildMode.Example
        assert(false);
    end

    if~isempty(configInfo)&&configInfo.EnableDebugging
        config='debug';
    else
        config='optim';
    end
    buildInfo.addTMFTokens('EMC_CONFIG',config);

    invokeTFLCallbacks(bldParams,buildInfo,configInfo);


    stdPath=fullfile(matlabroot,'extern','include');
    buildInfo.addIncludePaths(stdPath);

    targetName=GetTokenValue(buildInfo,'MLC_TARGET_NAME','BuildArgs');
    unloadMexDLL(targetName,project.BldDirectory,project.OutDirectory);
    targetLangIsC=isempty(findprop(configInfo,'TargetLang'))||strcmp(configInfo.TargetLang,'C');
    compilerInfo=compilerman(false,targetLangIsC,true);
    compilerInfo.targetLangIsC=targetLangIsC;

    if strcmp(compilerInfo.compilerName,'lcc64')&&strcmpi(bldParams.project.Client,'codegen')
        href='<a href="Mathworks: compiler support">https://www.mathworks.com/support/compilers.html</a>';
        ccwarningid('Coder:buildProcess:defaultCompilerJITBailout',href);
    end


    compilerInfo.codingForCuda=~isempty(bldParams.configInfo.GpuConfig)&&bldParams.configInfo.GpuConfig.Enabled&&...
    bldParams.configInfo.GpuConfig.isCUDACodegen();


    mexVersionDir=fullfile(matlabroot,'extern','version');
    if targetLangIsC
        mexVersionFile='c_mexapi_version.c';
    else
        mexVersionFile='cpp_mexapi_version.cpp';
    end
    if compilerInfo.codingForCuda
        buildDir=emcGetBuildDirectory(buildInfo,bldMode);
        copyfile(fullfile(mexVersionDir,mexVersionFile),buildDir,'f');
        mexVersionDir=buildDir;
    end

    if bldMode==coder.internal.BuildMode.Normal
        emcRunPostCodeGenCommand(project,buildInfo,configInfo);
        buildInfo.addSourceFiles(mexVersionFile,mexVersionDir);
    end

    if contains(project.OutDirectory,'$(START_DIR)')
        project.OutDirectory=buildInfo.Settings.LocalAnchorDir;
    end

    targetDir=project.OutDirectory;

    useShippingCudaLibs=~isempty(configInfo.GpuConfig)&&configInfo.GpuConfig.UseShippingLibs;
    if compilerInfo.codingForCuda&&useShippingCudaLibs

        if isunix
            cudaincludepath=fullfile(matlabroot,'sys/cuda/glnxa64/cuda/include');
            buildInfo.addIncludePaths(cudaincludepath);
            buildInfo.addLinkFlags(['-I"',cudaincludepath,'"']);
        else
            cudaincludepath=fullfile(matlabroot,'sys\cuda\win64\cuda\include');
            buildInfo.addIncludePaths(cudaincludepath);
            buildInfo.addLinkFlags(['-I"',cudaincludepath,'"']);
        end
    end

    addStandardInfoForML(buildInfo,~targetLangIsC,false,GetTokenValue(buildInfo,'MLC_TARGET_NAME','BuildArgs'),configInfo);

    genNinjafile(project,buildInfo,bldMode,compilerInfo,configInfo);
    buildResults=runMakefile(buildInfo,configInfo,targetName,targetDir,bldMode);
end


function invokeTFLCallbacks(bldParams,buildInfo,configInfo)

    project=bldParams.project;
    bldDir=project.BldDirectory;
    tflControl=bldParams.tflControl;
    configFile=fullfile(bldDir,'tmp_configinfo.mat');
    save(configFile,'configInfo');
    tflControl.runFcnImpCallbacks(bldDir);
    delete(configFile);
    emcAddTflUsageInfoToBuildInfo(buildInfo,tflControl,bldDir);
end


function buildResults=runMakefile(buildInfo,configInfo,targetName,targetDir,bldMode)
    buildDir=emcGetBuildDirectory(buildInfo,bldMode);
    dstFile=[targetName,'.',mexext];

    oldDir=cd(buildDir);

    removeOldTarget(dstFile,targetDir,buildDir);

    if bldMode==coder.internal.BuildMode.Normal
        try
            save(fullfile(buildDir,'buildInfo.mat'),'buildInfo');
        catch
        end
    end

    [status,result,buildResults]=executeMakefile(buildInfo,configInfo,oldDir,buildDir);
    checkStatus(status,result,oldDir);

    cd(oldDir);

    if~buildResults.isBuildOnly&&buildResults.success
        [status,result]=verifyBuildComplete(dstFile,targetDir,buildDir,result);
        checkStatus(status,result);
    end

end


function[status,result]=verifyBuildComplete(dstFile,dstDir,buildDir,result)
    status=0;
    try
        srcPath=fullfile(buildDir,dstFile);
        if~isfile(srcPath)
            status=1;
            disp(result);
            result='Failed to build target';
        else
            fstat=dir(srcPath);
            if fstat.bytes==0
                status=1;
                disp(result);
                result='Failed to build target';
            else
                dstPath=fullfile(dstDir,dstFile);
                if~strcmp(srcPath,dstPath)
                    clear(dstFile);
                    [status,result]=copyfile(srcPath,dstPath,'f');
                    if status==0
                        error(message('Coder:buildProcess:CopyfileError',srcPath,dstPath));
                    else
                        status=0;
                    end
                end
            end
        end
        fschange(pwd);
    catch err
        rethrow(err);
    end
end


function removeOldTarget(dstFile,outDir,bldDir)
    emcRemoveFile(outDir,dstFile);
    emcRemoveFile(bldDir,dstFile);
end


function[status,result,buildResults]=executeMakefile(buildInfo,configInfo,oldDir,buildDir)
    targetName=GetTokenValue(buildInfo,'EMC_PROJECT');
    result=[];
    loc=fullfile(buildDir,'build',computer('arch'));
    if~isfolder(loc)
        [~]=mkdir(loc);
    end
    logFile=fullfile(loc,'buildLog.log');
    if ispc
        cmdLine=[targetName,'_mex.bat > "',logFile,'"'];
    else
        cmdLine=['sh ',targetName,'_mex.sh > "',logFile,'"'];
    end

    genCodeOnly=isprop(configInfo,'GenCodeOnly')&&configInfo.GenCodeOnly;
    if genCodeOnly
        status=0;
        result=message('Coder:buildProcess:compilationSuppressed').getString;
        buildResults=coder.internal.MakeResult(result,cmdLine,true,'',true);
    else
        try
            status=system(cmdLine);
            buildLog=fileread(logFile);
            success=true;
            errMsg='';
            if status~=0
                if isprop(configInfo,'TargetLang')
                    lang=configInfo.TargetLang;
                else
                    lang='C';
                end
                errMsg=...
                message('Coder:buildProcess:compilationErrorStatus',...
                lang).getString;
                status=0;
                success=false;
            end
            buildResults=coder.internal.MakeResult(buildLog,cmdLine,false,errMsg,success);
        catch err
            disp(result);
            cd(oldDir);
            rethrow(err);
        end
    end
    fschange(pwd);
end


function checkStatus(status,result,oldDir)
    if status~=0
        if(nargin>2)&&~isempty(oldDir)
            cd(oldDir);
        end
        error(message('Coder:buildProcess:compilationFailed',result));
    end
end


function unloadMexDLL(mexFunctionName,bldDir,outDir)
    clear_mex(mexFunctionName);
    [~,mexs]=inmem;
    if any(strcmp(mexFunctionName,mexs))
        error(message('Coder:buildProcess:mexFileLocked'));
    end


    mexfile=fullfile(bldDir,[mexFunctionName,'.',mexext]);
    status=isMexInMemory(mexfile);
    if status
        error(message('Coder:buildProcess:mexStillInMemory',mexfile));
    end

    mexfile=fullfile(outDir,[mexFunctionName,'.',mexext]);
    status=isMexInMemory(mexfile);
    if status
        error(message('Coder:buildProcess:mexStillInMemory',mexfile));
    end
end


function clear_mex(varargin)
    clear(varargin{:});
end

function genNinjafile(project,buildInfo,bldMode,compilerInfo,configInfo)
    parallelCodeGen=false;

    parallelFeatures=project.FeatureControl.EMLParallelCodeGen;

    if compilerInfo.codingMicrosoftMakefile
        parallelCodeGen=parallelFeatures;
    elseif compilerInfo.codingMinGWMakefile
        parallelCodeGen=parallelFeatures;
    elseif compilerInfo.codingLcc64Makefile
        if~compilerInfo.targetLangIsC
            error(message('Coder:configSet:lccNotMexCPPcompiler'));
        end
    elseif compilerInfo.codingUnixMakefile
        parallelCodeGen=parallelFeatures;
    elseif compilerInfo.codingIntelMakefile
        parallelCodeGen=parallelFeatures;
    else
        error(message('Coder:buildProcess:unsupportedCompiler'));
    end
    buildInfo.addTMFTokens('EMC_COMPILER',compilerInfo.compilerName);
    EmitNinjaFile(project,buildInfo,bldMode,compilerInfo,configInfo,parallelCodeGen);
end


