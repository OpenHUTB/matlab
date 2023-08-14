function[results,reportName]=checkGpuInstallPrivate(varargin)





    gpuEnvConfigObj=coder.internal.validateArgs(varargin{:});

    if~strcmp(gpuEnvConfigObj.Hardware,'host')
        assert(isprop(gpuEnvConfigObj,'HardwareObject'));
        if isempty(gpuEnvConfigObj.HardwareObject)
            error(message('gpucoder:system:gpu_check_hwobj_empty',gpuEnvConfigObj.Hardware));
        end
    else

        setEnvironmentHost(gpuEnvConfigObj);
    end


    htmlFile=-1;
    if gpuEnvConfigObj.GenReport
        reportName=fullfile(pwd,'gpucoderSetupReport.html');
        htmlFile=fopen(reportName,'w+','n','UTF-8');
        if htmlFile==-1
            error(message('gpucoder:system:file_open_error_report'));
        end
    else
        reportName='';
    end


    checkGpuErrorList={};
    installQuiet=gpuEnvConfigObj.Quiet;
    isMO=isMatlabOnline();

    results.gpu=false;
    results.cuda=false;
    results.cudnn=false;
    results.tensorrt=false;
    results.hostcompiler=false;
    results.basiccodegen=false;
    results.basiccodeexec=false;
    results.deepcodegen=false;
    results.deepcodeexec=false;
    results.tensorrtdatatype=false;
    results.profiling=false;
    origGpuId=-1;


    computeWarnId='parallel:gpu:device:DeviceDeprecated';
    warning('off',computeWarnId);


    if strcmp(gpuEnvConfigObj.Hardware,'host')
        [results.gpu,origGpuId,revertGpu,cc,checkGpuErrorList]=checkForCompatibleGPUHost(htmlFile,gpuEnvConfigObj.GpuId,installQuiet,checkGpuErrorList);
        [results.cuda,checkGpuErrorList]=checkCUDAEnvironmentHost(htmlFile,installQuiet,checkGpuErrorList);


        if~isempty(gpuEnvConfigObj.DeepLibTarget)

            [results.cudnn,checkGpuErrorList]=checkCUDNNEnvironmentHost(htmlFile,isMO,installQuiet,checkGpuErrorList);

            if strcmp(gpuEnvConfigObj.DeepLibTarget,'tensorrt')
                [results.tensorrt,checkGpuErrorList]=checkTensorRTEnvironmentHost(htmlFile,isMO,installQuiet,checkGpuErrorList);
            end
        end


        if(gpuEnvConfigObj.Profiling)
            [results.profiling,checkGpuErrorList]=checkProfilingEnvironment(htmlFile,installQuiet,checkGpuErrorList);
        end


        [results.hostcompiler,checkGpuErrorList]=checkForCompatibleHostCompiler(htmlFile,installQuiet,checkGpuErrorList);
    else
        [results.gpu,cc,checkGpuErrorList]=checkForCompatibleGPUBoard(htmlFile,gpuEnvConfigObj.HardwareObject,gpuEnvConfigObj.GpuId,installQuiet,checkGpuErrorList);
        [results.cuda,checkGpuErrorList]=checkCUDAEnvironmentBoard(htmlFile,gpuEnvConfigObj.HardwareObject,installQuiet,checkGpuErrorList);


        if~isempty(gpuEnvConfigObj.DeepLibTarget)

            [results.cudnn,checkGpuErrorList]=checkCUDNNEnvironmentBoard(htmlFile,gpuEnvConfigObj.HardwareObject,installQuiet,checkGpuErrorList);

            if strcmp(gpuEnvConfigObj.DeepLibTarget,'tensorrt')
                [results.tensorrt,checkGpuErrorList]=checkTensorRTEnvironmentBoard(htmlFile,gpuEnvConfigObj.HardwareObject,installQuiet,checkGpuErrorList);
            end
        end
    end

    if htmlFile~=-1
        printTableFooter(htmlFile);
    end


    minComputeCap=coder.GpuCodeConfig.DefaultComputeCapability;
    if results.gpu
        tmpCfg=coder.gpuConfig;
        try
            tmpCfg.GpuConfig.ComputeCapability=cc;
            computeCap=cc;
        catch e
            computeCap=minComputeCap;
        end
    else
        computeCap=minComputeCap;
    end



    if(gpuEnvConfigObj.BasicCodegen&&results.cuda)
        buildDir='~/buildDir_codegentest';
        if htmlFile~=-1
            printBreaks(htmlFile);
            printTableHeader(htmlFile,string(message('gpucoder:system:table_header_basic_codegen_checks')));
        end


        if strcmp(gpuEnvConfigObj.Hardware,'host')
            if results.hostcompiler
                [results.basiccodegen,tempDir,checkGpuErrorList]=checkBasicCodegen(htmlFile,computeCap,installQuiet,checkGpuErrorList);
            end
        else
            [results.basiccodegen,tempDir,checkGpuErrorList]=checkBasicCodegenBoard(htmlFile,gpuEnvConfigObj.Hardware,...
            gpuEnvConfigObj.HardwareObject,gpuEnvConfigObj.GpuId,buildDir,computeCap,installQuiet,checkGpuErrorList);
        end


        if(gpuEnvConfigObj.BasicCodeexec&&results.basiccodegen&&results.gpu)
            if strcmp(gpuEnvConfigObj.Hardware,'host')
                if results.hostcompiler
                    [results.basiccodeexec,checkGpuErrorList]=checkBasicCodeExecution(htmlFile,tempDir,installQuiet,checkGpuErrorList);
                end
            else
                [results.basiccodeexec,checkGpuErrorList]=checkBasicCodeExecutionBoard(htmlFile,tempDir,gpuEnvConfigObj.HardwareObject,...
                gpuEnvConfigObj.ExecTimeout,gpuEnvConfigObj.GenReport,installQuiet,checkGpuErrorList);
            end
        end

        if htmlFile~=-1
            printTableFooter(htmlFile);
        end


        if results.basiccodegen
            cleanupCodegen(tempDir);
            if~strcmp(gpuEnvConfigObj.Hardware,'host')
                cmd=['rm -rf ',buildDir];
                system(gpuEnvConfigObj.HardwareObject,cmd);
            end
        end

    end






    if(gpuEnvConfigObj.DeepCodegen&&results.cuda&&results.cudnn)
        dltarget=gpuEnvConfigObj.DeepLibTarget;
        buildDir='~/buildDir_dlcodegentest';
        codegenAttempted=false;

        if htmlFile~=-1
            printType='';
            if~strcmp(gpuEnvConfigObj.DataType,'fp32')
                printType=upper(gpuEnvConfigObj.DataType);
            end
            printBreaks(htmlFile);
            printTableHeader(htmlFile,string(message('gpucoder:system:table_header_dl_codegen_checks',getDltargetDisp(dltarget),printType)));
        end

        if strcmp(dltarget,'cudnn')
            codegenAttempted=true;
            computeCheck=true;

            if strcmp(gpuEnvConfigObj.Hardware,'host')
                if results.hostcompiler
                    [results.deepcodegen,tempDir,checkGpuErrorList]=checkDeepCodegen(htmlFile,dltarget,computeCap,installQuiet,checkGpuErrorList);
                end
            else
                [results.deepcodegen,tempDir,checkGpuErrorList]=checkDeepCodegenBoard(htmlFile,dltarget,gpuEnvConfigObj.Hardware,...
                gpuEnvConfigObj.HardwareObject,gpuEnvConfigObj.GpuId,buildDir,computeCap,installQuiet,checkGpuErrorList);
            end
        elseif strcmp(dltarget,'tensorrt')
            if results.tensorrt
                codegenAttempted=true;
                if strcmp(gpuEnvConfigObj.Hardware,'host')
                    if results.hostcompiler
                        [results.deepcodegen,tempDir,checkGpuErrorList]=checkDeepCodegen(htmlFile,dltarget,computeCap,installQuiet,checkGpuErrorList);
                    end
                else
                    [results.deepcodegen,tempDir,checkGpuErrorList]=checkDeepCodegenBoard(htmlFile,dltarget,gpuEnvConfigObj.Hardware,...
                    gpuEnvConfigObj.HardwareObject,gpuEnvConfigObj.GpuId,buildDir,computeCap,installQuiet,checkGpuErrorList);
                end
            end

            if results.gpu&&results.tensorrt
                if strcmp(gpuEnvConfigObj.Hardware,'host')
                    if results.hostcompiler
                        [results.tensorrtdatatype,checkGpuErrorList]=checkTensorRTComputeForPrecision(htmlFile,gpuEnvConfigObj,installQuiet,checkGpuErrorList);
                    end
                else
                    [results.tensorrtdatatype,checkGpuErrorList]=checkTensorRTComputeForPrecisionBoard(htmlFile,gpuEnvConfigObj,installQuiet,checkGpuErrorList);
                end
                computeCheck=results.tensorrtdatatype;
            end
        end

        if(results.deepcodegen&&gpuEnvConfigObj.DeepCodeexec&&results.gpu&&computeCheck)
            if strcmp(gpuEnvConfigObj.Hardware,'host')
                if results.hostcompiler
                    [results.deepcodeexec,checkGpuErrorList]=checkDeepCodeExecution(htmlFile,dltarget,tempDir,installQuiet,checkGpuErrorList);
                end
            else
                [results.deepcodeexec,checkGpuErrorList]=checkDeepCodeExecutionBoard(htmlFile,dltarget,tempDir,gpuEnvConfigObj.HardwareObject,...
                gpuEnvConfigObj.ExecTimeout,gpuEnvConfigObj.GenReport,installQuiet,checkGpuErrorList);
            end
        end

        if htmlFile~=-1
            printTableFooter(htmlFile);
        end


        if codegenAttempted&&results.deepcodegen
            cleanupCodegen(tempDir);
            if~strcmp(gpuEnvConfigObj.Hardware,'host')
                cmd=['rm -rf ',buildDir];
                system(gpuEnvConfigObj.HardwareObject,cmd);
            end
        end

    end


    if strcmp(gpuEnvConfigObj.Hardware,'host')&&origGpuId>0&&revertGpu
        gpuDevice(origGpuId);
    end


    warning('on',computeWarnId);

    if htmlFile~=-1
        printEndOfReport(htmlFile);
        fclose(htmlFile);
    else
        if installQuiet
            runFinalCheck(gpuEnvConfigObj,results,checkGpuErrorList);
        end
    end

end


function[status,origGpuId,revertGpu,cc,checkGpuErrorList]=checkForCompatibleGPUHost(htmlFile,idx,installQuiet,checkGpuErrorList)

    headString=string(message('gpucoder:system:table_compatible_gpu'));
    msgString='';
    status=true;
    gpuName='';
    boardName='';
    cc='';
    origGpuId=-1;
    revertGpu=false;

    numGpu=gpuDeviceCount;
    if numGpu>0
        if idx+1<1||idx+1>numGpu
            msgString=string(message('gpucoder:system:invalid_gpu_id',idx,['0:',num2str(numGpu-1)]));
            status=false;
        end

        if status

            try
                origGpuDev=gpuDevice;
                origGpuId=origGpuDev.Index;

                if origGpuId==idx+1

                    gDev=origGpuDev;
                    gpuName=gDev.Name;
                else

                    gDev=gpuDevice(idx+1);
                    gpuName=gDev.Name;
                    revertGpu=true;
                end
            catch e
                msgString=string(message('gpucoder:system:no_compatible_driver'));
                status=false;
            end


            if(status)
                if(~gDev.DeviceSupported)
                    msgString=string(message('gpucoder:system:unsupported_gpu',idx));
                    status=false;
                else

                    cc=gDev.ComputeCapability;
                    ccMaj=str2double(cc(1));
                    ccMin=str2double(cc(3));
                    if((ccMaj<3)||((ccMaj==3)&&(ccMin<2)))
                        msgString=string(message('gpucoder:system:unsupported_cc',idx,cc));
                        status=false;
                    elseif ccMaj<6
                        msgString=string(message('gpucoder:system:device_deprecated_warn',cc));
                    end
                end
            end
        end
    else
        msgString=string(message('gpucoder:system:no_gpus'));
        status=false;
    end

    if htmlFile~=-1
        initializeReport(htmlFile,boardName,gpuName);
        printTableHeader(htmlFile,string(message('gpucoder:system:table_header_env_checks')));
        printTableRow(htmlFile,headString,status,msgString);
    else
        checkGpuErrorList=printStatus(headString,status,msgString,installQuiet,checkGpuErrorList);
    end

end


function[status,cc,checkGpuErrorList]=checkForCompatibleGPUBoard(htmlFile,hwobj,idx,installQuiet,checkGpuErrorList)
    headString=string(message('gpucoder:system:table_compatible_gpu'));
    msgString='';
    status=true;
    gpuName='';
    cc='';
    numGpu=length(hwobj.GPUInfo);


    if idx+1<1||idx+1>numGpu
        msgString=string(message('gpucoder:system:invalid_gpu_id',idx,['0:',num2str(numGpu-1)]));
        status=false;
    end


    if(status)
        [cc,gpuName]=getBoardDetails(hwobj,idx);
        ccMaj=str2double(cc(1));
        ccMin=str2double(cc(3));
        if((ccMaj<3)||((ccMaj==3)&&(ccMin<2)))
            msgString=string(message('gpucoder:system:unsupported_cc',idx,cc));
            status=false;
        elseif ccMaj<6
            msgString=string(message('gpucoder:system:device_deprecated_warn',cc));
        end
    end

    if htmlFile~=-1
        initializeReport(htmlFile,hwobj.BoardName,gpuName);
        printTableHeader(htmlFile,string(message('gpucoder:system:table_header_env_checks')));
        printTableRow(htmlFile,headString,status,msgString);
    else
        checkGpuErrorList=printStatus(headString,status,msgString,installQuiet,checkGpuErrorList);
    end

end


function[hostStatus,checkGpuErrorList]=checkCUDAEnvironmentHost(htmlFile,installQuiet,checkGpuErrorList)
    hostStatus=false;
    headString=string(message('gpucoder:system:table_cuda_env'));
    msgString='';
    libs={'cudart','cufft','cusolver','cublas'};
    libNames={message('gpucoder:system:table_libname_runtime').getString,...
    message('gpucoder:system:table_libname_cufft').getString,...
    message('gpucoder:system:table_libname_cusolver').getString,...
    message('gpucoder:system:table_libname_cublas').getString};
    subMsgString=repmat("",[4,1]);
    libStatuses=[false,false,false,false];

    if ispc
        cuPath=getenv('CUDA_PATH');
        if(isempty(cuPath))
            msgString=string(message('gpucoder:system:no_cuda_env_var'));
            if htmlFile~=-1
                printTableRow(htmlFile,headString,hostStatus,msgString);
            else
                checkGpuErrorList=printStatus(headString,hostStatus,msgString,installQuiet,checkGpuErrorList);
            end
            return;
        end

        nvccCmd=fullfile(cuPath,'bin','nvcc.exe');
        nvccCmd=['"',nvccCmd,'" --version'];
        libPaths={fullfile(cuPath,'lib','x64')};
    else
        cuLibPath=getenv('LD_LIBRARY_PATH');
        nvccCmd='nvcc --version';
        libPaths=strsplit(cuLibPath,':');
    end


    for jdx=1:numel(libs)
        if ispc
            curLib=[libs{jdx},'.lib'];
        else
            curLib=['lib',libs{jdx},'.so'];
        end
        for kdx=1:numel(libPaths)
            found=0;
            listing=dir(libPaths{kdx});
            for fIdx=3:numel(listing)
                found=contains(listing(fIdx).name,curLib);
                if(found)
                    libStatuses(jdx)=true;
                    break;
                end
            end
            if(found)
                break;
            end
        end
    end


    [status,~]=system(nvccCmd);
    if(status~=0)
        msgString=string(message('gpucoder:system:nvcc_cmd_failed'));
    end


    if((status==0)&&all(libStatuses))
        hostStatus=true;
    end


    if(~hostStatus)
        for jdx=1:numel(libs)
            if(~libStatuses(jdx))
                subMsgString(jdx)=string(message('gpucoder:system:no_cuda_library',libNames{jdx}));
            end
        end
    end


    if htmlFile~=-1
        printSubTable(htmlFile,headString,hostStatus,msgString,libNames,libStatuses,subMsgString);
    else
        checkGpuErrorList=printStatus(headString,hostStatus,msgString,...
        installQuiet,checkGpuErrorList);
        for jdx=1:numel(libs)
            printSubStatus(libNames{jdx},libStatuses(jdx),subMsgString(jdx),...
            installQuiet,checkGpuErrorList);
        end
    end

end


function[hostStatus,checkGpuErrorList]=checkCUDAEnvironmentBoard(htmlFile,hwObj,installQuiet,checkGpuErrorList)
    hostStatus=false;
    headString=string(message('gpucoder:system:table_cuda_env'));
    msgString='';
    libs={'libcudart.so','libcufft.so','libcusolver.so','libcublas.so'};
    libNames={message('gpucoder:system:table_libname_runtime').getString,...
    message('gpucoder:system:table_libname_cufft').getString,...
    message('gpucoder:system:table_libname_cusolver').getString,...
    message('gpucoder:system:table_libname_cublas').getString};

    subMsgString=repmat("",[4,1]);

    libStatuses=findLibrariesOnBoard(hwObj,libs);


    status=isprop(hwObj,'CUDAVersion')&&~isempty(hwObj.CUDAVersion);
    if~status
        msgString=string(message('gpucoder:system:nvcc_cmd_failed_board'));
    end


    if(status&&all(libStatuses))
        hostStatus=true;
    end


    if(~hostStatus)
        for jdx=1:numel(libs)
            if(~libStatuses(jdx))
                subMsgString(jdx)=string(message('gpucoder:system:no_cuda_library_board',libNames{jdx}));
            end
        end
    end


    if htmlFile~=-1
        printSubTable(htmlFile,headString,hostStatus,msgString,libNames,libStatuses,subMsgString);
    else
        checkGpuErrorList=printStatus(headString,hostStatus,msgString,...
        installQuiet,checkGpuErrorList);
        for jdx=1:numel(libs)
            printSubStatus(libNames{jdx},libStatuses(jdx),subMsgString(jdx),...
            installQuiet,checkGpuErrorList);
        end
    end

end

function libStatuses=findLibrariesOnBoard(hwObj,libs)

    libStatuses=zeros(numel(libs),1,'logical');
    libStatuses=findLibrariesOnSystemPath(hwObj,libs,libStatuses);
    libStatuses=findLibraryesOnUserPath(hwObj,libs,libStatuses);

    function libStatuses=findLibrariesOnSystemPath(hwObj,libs,libStatuses)
        command='ldconfig -p';

        try
            output=system(hwObj,command);
        catch
            return;
        end

        for i=1:numel(libs)
            if~libStatuses(i)&&contains(output,libs(i))
                libStatuses(i)=true;
            end
        end
    end

    function libStatuses=findLibraryesOnUserPath(hwObj,libs,libStatuses)
        echoCmd='echo $LD_LIBRARY_PATH';
        cuLibPath=strtrim(system(hwObj,echoCmd));
        libPaths=strsplit(cuLibPath,':');


        for jdx=1:numel(libs)
            if libStatuses(jdx)
                continue;
            end
            for kdx=1:numel(libPaths)
                if~isempty(libPaths{kdx})
                    lscmd=['ls ',libPaths{kdx}];
                    try
                        listing=system(hwObj,lscmd);
                    catch
                        continue;
                    end
                    found=contains(listing,curLib);
                    if found
                        libStatuses(jdx)=true;
                        break;
                    end
                end
            end
        end
    end

end


function[status,checkGpuErrorList]=checkCUDNNEnvironmentHost(htmlFile,isMO,installQuiet,checkGpuErrorList)
    cudnnPath=getenv('NVIDIA_CUDNN');
    status=true;
    headString=string(message('gpucoder:system:table_cudnn_env'));
    msgString='';

    if(isempty(cudnnPath))
        msgString=string(message('gpucoder:system:no_cudnn_env_var'));
        status=false;
    end

    incDir=fullfile(cudnnPath,'include');
    incFile=fullfile(incDir,'cudnn.h');
    if(status)
        if(exist(incFile,'file')~=2)
            msgString=string(message('gpucoder:system:no_cudnn_header',incDir));
            status=false;
        end
    end

    if ispc
        libDir=fullfile(cudnnPath,'lib','x64');
        libFile='cudnn.lib';
    else
        libDir=fullfile(cudnnPath,'lib64');
        libFile='libcudnn.so';
    end

    if(status)
        if(exist(fullfile(libDir,libFile),'file')~=2)
            msgString=string(message('gpucoder:system:no_cudnn_library',libDir));
            status=false;
        end
    end

    if(status&&~isMO)
        dltarget=getDltargetDisp('cudnn');
        [status,msgString]=checkDlLibraryVersion(dltarget,incDir);
    end


    if htmlFile~=-1
        printTableRow(htmlFile,headString,status,msgString);
    else
        checkGpuErrorList=printStatus(headString,status,msgString,installQuiet,checkGpuErrorList);
    end
end


function[status,checkGpuErrorList]=checkCUDNNEnvironmentBoard(htmlFile,hwObj,installQuiet,checkGpuErrorList)
    status=isprop(hwObj,'cuDNNVersion')&&~isempty(hwObj.cuDNNVersion);
    headString=string(message('gpucoder:system:table_cudnn_env'));

    if~status
        msgString=string(message('nvidia:utils:CudnnNotAvailable'));
    else
        dltarget=getDltargetDisp('cudnn');
        [status,msgString]=checkDlLibraryVersionBoard(dltarget,hwObj.cuDNNVersion);
    end

    if htmlFile~=-1
        printTableRow(htmlFile,headString,status,msgString);
    else
        checkGpuErrorList=printStatus(headString,status,msgString,installQuiet,checkGpuErrorList);
    end
end


function[status,checkGpuErrorList]=checkTensorRTEnvironmentHost(htmlFile,isMO,installQuiet,checkGpuErrorList)
    tensorRTPath=getenv('NVIDIA_TENSORRT');
    status=true;
    headString=string(message('gpucoder:system:table_tensorrt_env'));
    msgString='';

    if status&&isempty(tensorRTPath)
        msgString=string(message('gpucoder:system:no_tensorrt_env_var'));
        status=false;
    end

    incDir=fullfile(tensorRTPath,'include');
    incFiles={'NvInfer.h','NvInferRuntime.h','NvInferRuntimeCommon.h','NvInferVersion.h'};
    for i=1:numel(incFiles)
        if status
            incFile=fullfile(incDir,incFiles{i});
            if exist(incFile,'file')~=2
                msgString=string(message('gpucoder:system:no_tensorrt_header',incDir,incFiles{i}));
                status=false;
            end
        end
    end

    libDir=fullfile(tensorRTPath,'lib');
    if isunix
        if(exist(fullfile(tensorRTPath,'lib64'),'dir')==7)
            libDir=fullfile(tensorRTPath,'lib64');
        end
        libFiles={'libnvinfer.so'};
    elseif ispc
        if(exist(fullfile(tensorRTPath,'lib','x64'),'dir')==7)
            libDir=fullfile(tensorRTPath,'lib','x64');
        end
        libFiles={'nvinfer.lib'};
    end

    for i=1:numel(libFiles)
        if status
            libFile=fullfile(libDir,libFiles{i});
            if exist(libFile,'file')~=2
                msgString=string(message('gpucoder:system:no_tensorrt_library',libDir,libFiles{i}));
                status=false;
            end
        end
    end

    if(status&&~isMO)
        dltarget=getDltargetDisp('tensorrt');
        [status,msgString]=checkDlLibraryVersion(dltarget,incDir);
    end

    if htmlFile~=-1
        printTableRow(htmlFile,headString,status,msgString);
    else
        checkGpuErrorList=printStatus(headString,status,msgString,installQuiet,checkGpuErrorList);
    end

end


function[status,checkGpuErrorList]=checkTensorRTEnvironmentBoard(htmlFile,hwObj,installQuiet,checkGpuErrorList)
    status=isprop(hwObj,'TensorRTVersion')&&~isempty(hwObj.TensorRTVersion);
    headString=string(message('gpucoder:system:table_tensorrt_env'));

    if~status
        msgString=string(message('nvidia:utils:TensorrtNotAvailable'));
    else
        dltarget=getDltargetDisp('tensorrt');
        [status,msgString]=checkDlLibraryVersionBoard(dltarget,hwObj.TensorRTVersion);
    end

    if htmlFile~=-1
        printTableRow(htmlFile,headString,status,msgString);
    else
        checkGpuErrorList=printStatus(headString,status,msgString,installQuiet,checkGpuErrorList);
    end

end


function[status,msgString]=checkDlLibraryVersion(dltarget,includeDir)
    status=true;
    msgString='';
    fileName=['get',dltarget,'Version'];
    mexFunc=str2func(fileName);
    fileName=[fileName,'.cpp'];

    includeDir=['-I',includeDir];%#ok<NASGU>
    cudaIncludeDir=['-I',coder.internal.getCudaPath(),filesep,'include'];%#ok<NASGU>

    tempFolder=tempname;
    mkdir(tempFolder);
    oldDir=cd(tempFolder);
    gpucoder_dir=fullfile(matlabroot,'toolbox','gpucoder','gpucoder','+coder','+internal');

    try
        fileNames={fileName};
        copyFilesToCurrDir(fileNames,gpucoder_dir);
        evalc('mex(fileName, includeDir, cudaIncludeDir)');
        [major,minor]=mexFunc();
        [result,supportedVer]=coder.internal.isLibraryVersionSupported(dltarget,major,minor);
    catch e
        msgString=string(message('gpucoder:system:library_ver_error',dltarget,e.message));
        status=false;
    end

    if status&&~result
        providedVer=[num2str(major),'.',num2str(minor)];
        msgString=string(message('gpucoder:system:library_ver_mismatch_warn',dltarget,supportedVer,providedVer));
    end

    cd(oldDir)
    cleanupCodegen(tempFolder);

end


function[status,msgString]=checkDlLibraryVersionBoard(dltarget,providedVer)
    status=true;
    msgString='';

    majorMinor=strsplit(providedVer,'.');
    major=str2double(majorMinor{1});
    minor=str2double(majorMinor{2});
    [result,supportedVer]=coder.internal.isLibraryVersionSupported(dltarget,major,minor);

    if~result
        msgString=string(message('gpucoder:system:library_ver_mismatch_warn',dltarget,supportedVer,providedVer));
    end

end


function[status,checkGpuErrorList]=checkForCompatibleHostCompiler(htmlFile,installQuiet,checkGpuErrorList)


    status=true;
    headString=string(message('gpucoder:system:table_host_compiler'));
    msgString='';

    try
        selectedCompilerInfo=mex.getCompilerConfigurations('C++','Selected');
        shortNameSelected=selectedCompilerInfo.ShortName;

        installedCompilerInfo=mex.getCompilerConfigurations('C++','Installed');
        shortNamesInstalled=cell(1,length(installedCompilerInfo));
        for i=1:length(installedCompilerInfo)
            shortNamesInstalled{i}=installedCompilerInfo(i).ShortName;
        end

        supportedCompilers=coder.gpu.getSupportedTCMap;
        supportedCompilerFound=any(isKey(supportedCompilers,shortNamesInstalled));
        supportedCompilerSelected=any(isKey(supportedCompilers,shortNameSelected));

        if~supportedCompilerFound
            status=false;
            msgString=string(message('gpucoder:system:no_supported_host_compiler'));
        elseif~supportedCompilerSelected
            status=false;
            msgString=string(message('gpucoder:system:unsupported_host_compiler'...
            ,selectedCompilerInfo.Name,'mex -setup C++'));
        end
    catch
        status=false;
        msgString=string(message('gpucoder:system:no_supported_host_compiler'));
    end


    if htmlFile~=-1
        printTableRow(htmlFile,headString,status,msgString);
    else
        checkGpuErrorList=printStatus(headString,status,msgString,...
        installQuiet,checkGpuErrorList);
    end

end



function[status,tempFolder,checkGpuErrorList]=checkBasicCodegen(htmlFile,computeCap,installQuiet,checkGpuErrorList)
    gCfg=coder.gpuConfig;
    gCfg.GpuConfig.SafeBuild=1;
    if~isempty(computeCap)
        gCfg.GpuConfig.ComputeCapability=computeCap;
    end

    xIn=genTestData();
    status=true;
    headString=string(message('gpucoder:system:table_basic_codegen'));
    msgString='';

    tempFolder=tempname;
    mkdir(tempFolder);
    oldDir=cd(tempFolder);
    changeBack=onCleanup(@()cd(oldDir));
    gpucoder_dir=fullfile(matlabroot,'toolbox','gpucoder','gpucoder','+coder','+internal');


    try
        fileNames={'gpuSimpleTest.m'};
        copyFilesToCurrDir(fileNames,gpucoder_dir);
        evalc('codegen -config gCfg -args {xIn} gpuSimpleTest');
    catch e
        reportLocation=fullfile(tempFolder,'codegen','mex','gpuSimpleTest','html','report.mldatx');
        msgString=string(message('gpucoder:system:codegen_failed_report',e.identifier,reportLocation));
        status=false;
    end

    if htmlFile~=-1
        printTableRow(htmlFile,headString,status,msgString);
    else
        checkGpuErrorList=printStatus(headString,status,msgString,installQuiet,checkGpuErrorList);
    end

end



function[status,tempFolder,checkGpuErrorList]=checkBasicCodegenBoard(htmlFile,hardware,hwObj,idx,buildDir,computeCap,installQuiet,checkGpuErrorList)
    cfg_hsp=coder.gpuConfig('exe');
    cfg_hsp.GpuConfig.SafeBuild=1;
    cfg_hsp.GpuConfig.SelectCudaDevice=idx;
    if~isempty(computeCap)
        cfg_hsp.GpuConfig.ComputeCapability=computeCap;
    end
    cfg_hsp.CustomSource='main.cu';
    cfg_hsp.CustomInclude='.';


    hwObj.setupCodegenContext;
    cfg_hsp.Hardware=coder.hardware(['NVIDIA ',hardware]);
    cfg_hsp.Hardware.BuildDir=buildDir;

    xIn=genTestData();
    status=true;
    headString=string(message('gpucoder:system:table_basic_codegen'));
    msgString='';

    tempFolder=tempname;
    mkdir(tempFolder);
    oldDir=cd(tempFolder);
    changeBack=onCleanup(@()cd(oldDir));
    gpucoder_dir=fullfile(matlabroot,'toolbox','gpucoder','gpucoder','+coder','+internal');


    try
        fileNames={'gpuSimpleTest.m','main.h','main.cu'};
        copyFilesToCurrDir(fileNames,gpucoder_dir);
        evalc('codegen -config cfg_hsp -args {xIn} gpuSimpleTest');
    catch e
        reportLocation=fullfile(tempFolder,'codegen','exe','gpuSimpleTest','html','report.mldatx');
        msgString=string(message('gpucoder:system:codegen_failed_report',e.identifier,reportLocation));
        status=false;
    end

    if htmlFile~=-1
        printTableRow(htmlFile,headString,status,msgString);
    else
        checkGpuErrorList=printStatus(headString,status,msgString,installQuiet,checkGpuErrorList);
    end

end



function[status,checkGpuErrorList]=checkBasicCodeExecution(htmlFile,cgDir,installQuiet,checkGpuErrorList)

    status=true;
    headString=string(message('gpucoder:system:table_basic_codeexec'));
    msgString='';

    oldDir=cd(cgDir);
    changeBack=onCleanup(@()cd(oldDir));

    try
        pf=gpuFuncDriver();
        if(any(pf))
            msgString=string(message('gpucoder:system:code_execution_failed'));
            status=false;
        end
    catch e
        msgString=string(message('gpucoder:system:code_execution_error',e.message));
        status=false;
    end

    if htmlFile~=-1
        printTableRow(htmlFile,headString,status,msgString);
    else
        checkGpuErrorList=printStatus(headString,status,msgString,installQuiet,checkGpuErrorList);
    end

end



function[status,checkGpuErrorList]=checkBasicCodeExecutionBoard(htmlFile,cgDir,hwObj,execTimeout,...
    genReport,installQuiet,checkGpuErrorList)

    status=true;
    headString=string(message('gpucoder:system:table_basic_codeexec'));
    msgString='';
    oldDir=cd(cgDir);
    changeBack=onCleanup(@()cd(oldDir));

    try
        pf=executeBoard(hwObj,hwObj.workspaceDir,execTimeout,genReport);
        if(any(pf))
            msgString=string(message('gpucoder:system:code_execution_failed'));
            status=false;
        end
    catch e
        msgString=string(message('gpucoder:system:code_execution_error',e.message));
        status=false;
    end

    if htmlFile~=-1
        printTableRow(htmlFile,headString,status,msgString);
    else
        checkGpuErrorList=printStatus(headString,status,msgString,installQuiet,checkGpuErrorList);
    end

end



function[status,checkGpuErrorList]=checkDLSupportPackage(htmlFile,dltarget,headString,installQuiet,checkGpuErrorList)

    status=true;
    msgString='';
    if~dlcoder_base.internal.isGpuCoderDLTargetsInstalled
        status=false;
        spkgname='GPU Coder Interface for Deep Learning Libraries';
        spkgbasecode='GPU_DEEPLEARNING_LIB';
        msgString=string(message('gpucoder:cnncodegen:missing_support_package',...
        getDltargetDisp(dltarget),spkgname,spkgbasecode));
    end

    if status
        return;
    end

    if htmlFile~=-1
        printTableRow(htmlFile,headString,status,msgString);
    else
        checkGpuErrorList=printStatus(headString,status,msgString,installQuiet,checkGpuErrorList);
    end

end

function[status,tempFolder,checkGpuErrorList]=checkDeepCodegen(htmlFile,dltarget,computeCap,installQuiet,checkGpuErrorList)

    headString=string(message('gpucoder:system:table_dl_codegen',getDltargetDisp(dltarget)));
    msgString='';
    tempFolder=tempname;

    [status,checkGpuErrorList]=checkDLSupportPackage(htmlFile,dltarget,headString,installQuiet,checkGpuErrorList);
    if~status
        return;
    end

    gCfg=coder.gpuConfig;
    gCfg.GpuConfig.SafeBuild=true;
    gCfg.TargetLang='C++';
    if~isempty(computeCap)
        gCfg.GpuConfig.ComputeCapability=computeCap;
    end

    switch dltarget
    case 'cudnn'
        dlConfig=coder.DeepLearningConfig('cudnn');
    case 'tensorrt'
        dlConfig=coder.DeepLearningConfig('tensorrt');
        dlConfig.DataType='fp32';
    end

    gCfg.DeepLearningConfig=dlConfig;

    xIn=ones(28,28,'uint8');
    ntwkfile='mnist.mat';

    mkdir(tempFolder);
    oldDir=cd(tempFolder);
    changeBack=onCleanup(@()cd(oldDir));
    shared_coder_dir=fullfile(matlabroot,'toolbox','shared','coder','coder','+coder','+internal');


    try
        fileNames={'dlEntryPointTest.m','mnist.mat','three_28x28.pgm'};
        copyFilesToCurrDir(fileNames,shared_coder_dir);
        evalc('codegen -config gCfg -args {xIn, coder.Constant(ntwkfile)} dlEntryPointTest');
    catch e
        reportLocation=fullfile(tempFolder,'codegen','mex','dlEntryPointTest','html','report.mldatx');
        msgString=string(message('gpucoder:system:codegen_failed_report',e.identifier,reportLocation));
        status=false;
    end

    if htmlFile~=-1
        printTableRow(htmlFile,headString,status,msgString);
    else
        checkGpuErrorList=printStatus(headString,status,msgString,installQuiet,checkGpuErrorList);
    end

end

function[status,tempFolder,checkGpuErrorList]=checkDeepCodegenBoard(htmlFile,dltarget,hardware,hwObj,idx,buildDir,computeCap,installQuiet,checkGpuErrorList)

    status=true;
    headString=string(message('gpucoder:system:table_dl_codegen',getDltargetDisp(dltarget)));
    msgString='';

    cfg_hsp=coder.gpuConfig('exe');
    cfg_hsp.GpuConfig.SafeBuild=1;
    cfg_hsp.TargetLang='C++';
    cfg_hsp.CustomSource='deepmain.cu';
    cfg_hsp.CustomInclude='.';
    cfg_hsp.GpuConfig.SelectCudaDevice=idx;
    if~isempty(computeCap)
        cfg_hsp.GpuConfig.ComputeCapability=computeCap;
    end


    hwObj.setupCodegenContext;
    cfg_hsp.Hardware=coder.hardware(['NVIDIA ',hardware]);
    cfg_hsp.Hardware.BuildDir=buildDir;

    switch lower(dltarget)
    case 'cudnn'
        dlConfig=coder.DeepLearningConfig('cudnn');
    case 'tensorrt'
        dlConfig=coder.DeepLearningConfig('tensorrt');
        dlConfig.DataType='fp32';
    end

    cfg_hsp.DeepLearningConfig=dlConfig;

    xIn=ones(28,28,'uint8');
    ntwkfile='mnist.mat';

    tempFolder=tempname;
    mkdir(tempFolder);
    oldDir=cd(tempFolder);
    changeBack=onCleanup(@()cd(oldDir));
    gpucoder_dir=fullfile(matlabroot,'toolbox','gpucoder','gpucoder','+coder','+internal');
    shared_coder_dir=fullfile(matlabroot,'toolbox','shared','coder','coder','+coder','+internal');


    try
        fileNames={'three_28x28.bin','deepmain.h','deepmain.cu'};
        copyFilesToCurrDir(fileNames,gpucoder_dir);
        fileNames={'dlEntryPointTest.m','mnist.mat','three_28x28.pgm'};
        copyFilesToCurrDir(fileNames,shared_coder_dir);
        evalc('codegen -config cfg_hsp -args {xIn, coder.Constant(ntwkfile)} dlEntryPointTest');
    catch e
        reportLocation=fullfile(tempFolder,'codegen','exe','dlEntryPointTest','html','report.mldatx');
        msgString=string(message('gpucoder:system:codegen_failed_report',e.identifier,reportLocation));
        status=false;
    end

    if htmlFile~=-1
        printTableRow(htmlFile,headString,status,msgString);
    else
        checkGpuErrorList=printStatus(headString,status,msgString,installQuiet,checkGpuErrorList);
    end

end


function[status,checkGpuErrorList]=checkTensorRTComputeForPrecision(htmlFile,gpuEnvConfigObj,installQuiet,checkGpuErrorList)
    status=true;
    msgString='';
    datatype=gpuEnvConfigObj.DataType;

    if strcmp(datatype,'fp32')
        return;
    end

    headString=string(message('gpucoder:system:table_dl_tensorrt_cc_check',upper(datatype)));

    [supported,cc,requiredcc]=coder.internal.isTensorRTDataTypeSupported(datatype);

    if~supported
        msgString=string(message('gpucoder:system:unsupported_tensorrt_datatype',cc,requiredcc,upper(datatype)));
        status=false;
    end

    if htmlFile~=-1
        printTableRow(htmlFile,headString,status,msgString);
    else
        checkGpuErrorList=printStatus(headString,status,msgString,installQuiet,checkGpuErrorList);
    end

end

function[status,checkGpuErrorList]=checkTensorRTComputeForPrecisionBoard(htmlFile,gpuEnvConfigObj,installQuiet,checkGpuErrorList)
    status=true;
    msgString='';
    datatype=gpuEnvConfigObj.DataType;

    if strcmp(datatype,'fp32')
        return;
    end

    headString=string(message('gpucoder:system:table_dl_tensorrt_cc_check',upper(datatype)));
    gpuID=gpuEnvConfigObj.GpuId;

    hwobj=gpuEnvConfigObj.HardwareObject;
    cc=getBoardDetails(hwobj,gpuID);
    [supported,cc,requiredcc]=coder.internal.isTensorRTDataTypeSupported(datatype,cc);

    if~supported
        msgString=string(message('gpucoder:system:unsupported_tensorrt_datatype',cc,requiredcc,upper(datatype)));
        status=false;
    end

    if htmlFile~=-1
        printTableRow(htmlFile,headString,status,msgString);
    else
        checkGpuErrorList=printStatus(headString,status,msgString,installQuiet,checkGpuErrorList);
    end

end



function[status,checkGpuErrorList]=checkDeepCodeExecution(htmlFile,dltarget,cgDir,installQuiet,checkGpuErrorList)


    status=true;
    headString=string(message('gpucoder:system:table_dl_codeexec',getDltargetDisp(dltarget)));
    msgString='';

    oldDir=cd(cgDir);
    changeBack=onCleanup(@()cd(oldDir));

    ntwkfile='mnist.mat';
    in=imread('three_28x28.pgm');

    try
        pf=executeDeep(in,ntwkfile);
        if(any(pf))
            msgString=string(message('gpucoder:system:code_execution_failed'));
            status=false;
        end
    catch e
        if isunix&&strcmpi(dltarget,'tensorrt')&&...
            ~isempty(regexp(e.message,'libnvinfer.so|libmyelin.so','once'))
            msgString=string(message('gpucoder:system:no_tensorrt_library_in_llp','LD_LIBRARY_PATH'));
        elseif ispc&&strcmpi(dltarget,'tensorrt')&&contains(e.message,'The specified module could not be found')
            msgString=string(message('gpucoder:system:no_tensorrt_library_in_llp','PATH'));
        else
            msgString=string(message('gpucoder:system:code_execution_error',e.message));
        end
        status=false;
    end

    if htmlFile~=-1
        printTableRow(htmlFile,headString,status,msgString);
    else
        checkGpuErrorList=printStatus(headString,status,msgString,installQuiet,checkGpuErrorList);
    end

end

function[status,checkGpuErrorList]=checkDeepCodeExecutionBoard(htmlFile,dltarget,cgDir,hwObj,...
    execTimeout,genReport,installQuiet,checkGpuErrorList)


    status=true;
    headString=string(message('gpucoder:system:table_dl_codeexec',getDltargetDisp(dltarget)));
    msgString='';

    oldDir=cd(cgDir);
    changeBack=onCleanup(@()cd(oldDir));

    ntwkfile='mnist.mat';
    in=imread('three_28x28.pgm');

    try
        pf=executeDeepBoard(hwObj,hwObj.workspaceDir,in,ntwkfile,execTimeout,genReport);
        if(any(pf))
            msgString=string(message('gpucoder:system:code_execution_failed'));
            status=false;
        end
    catch e
        if strcmpi(dltarget,'tensorrt')&&...
            ~isempty(regexp(e.message,'libnvinfer.so|libmyelin.so','once'))
            msgString=string(message('gpucoder:system:no_tensorrt_library_in_llp','LD_LIBRARY_PATH'));
        else
            msgString=string(message('gpucoder:system:code_execution_error',e.message));
        end
        status=false;
    end

    if htmlFile~=-1
        printTableRow(htmlFile,headString,status,msgString);
    else
        checkGpuErrorList=printStatus(headString,status,msgString,installQuiet,checkGpuErrorList);
    end

end


function[profilingStatus,checkGpuErrorList]=checkProfilingEnvironment(htmlFile,installQuiet,checkGpuErrorList)
    headString=string(message('gpucoder:system:table_profiling_env'));
    msgString='';

    [profilingStatus,msg]=coder.internal.checkProfilingEnvironment;

    if profilingStatus
        if~license('test','rtw_embedded_coder')
            msgString=string(message('gpucoder:profile:no_embedded_coder'));
            profilingStatus=false;
        end
    else
        msgString=string(msg);
    end

    if htmlFile~=-1
        printTableRow(htmlFile,headString,profilingStatus,msgString);
    else
        checkGpuErrorList=printStatus(headString,profilingStatus,msgString,installQuiet,checkGpuErrorList);
    end

end





function setEnvironmentHost(gpuEnvConfigObj)
    objCudaPath=strtrim(gpuEnvConfigObj.CudaPath);
    objCudnnPath=strtrim(gpuEnvConfigObj.CudnnPath);
    objTensorRTPath=strtrim(gpuEnvConfigObj.TensorrtPath);
    objNVTXPath=strtrim(gpuEnvConfigObj.NvtxPath);

    defCudaPath=coder.internal.getCudaPath();
    defCudnnPath=strtrim(getenv('NVIDIA_CUDNN'));
    defTensorRTPath=strtrim(getenv('NVIDIA_TENSORRT'));
    defNVTXPath=coder.internal.getNvtxPath();


    if checkValidPath(objCudaPath,defCudaPath)
        if ispc
            appendIfNotFound('CUDA_PATH',objCudaPath);
        else
            cudaDir=objCudaPath;
            libPath=fullfile(cudaDir,'lib64');
            nvccPath=fullfile(cudaDir,'bin');
            appendIfNotFound('LD_LIBRARY_PATH',libPath);
            appendIfNotFound('PATH',nvccPath);
        end
    end


    if checkValidPath(objCudnnPath,defCudnnPath)
        setenv('NVIDIA_CUDNN',objCudnnPath);
    end


    if checkValidPath(objTensorRTPath,defTensorRTPath)
        setenv('NVIDIA_TENSORRT',objTensorRTPath);
    end


    if checkValidPath(objNVTXPath,defNVTXPath)
        if ispc
            setenv('NVTOOLSEXT_PATH',objNVTXPath);
        else
            appendIfNotFound('LD_LIBRARY_PATH',objNVTXPath);
        end
    end

end


function ret=checkValidPath(objPath,defPath)

    if~isempty(objPath)&&exist(objPath,'dir')&&strcmp(objPath,defPath)==false
        ret=true;
    else
        ret=false;
    end
end

function appendIfNotFound(envVar,objPath)

    curEnvPath=getenv(envVar);
    objPathFound=false;
    folders=strsplit(curEnvPath,pathsep);
    for i=1:length(folders)
        if strcmp(folders{i},objPath)
            objPathFound=true;
            break;
        end
    end

    if~objPathFound
        setenv(envVar,[objPath,pathsep,curEnvPath]);
    end

end


function[]=runFinalCheck(params,results,checkGpuErrorList)

    if(~checkParamResult(params.BasicCodegen,results.basiccodegen)||...
        ~checkParamResult(params.BasicCodeexec,results.basiccodeexec)||...
        ~checkParamResult(params.DeepCodegen,results.deepcodegen)||...
        ~checkParamResult(params.DeepCodeexec,results.deepcodeexec)||...
        ~results.gpu||...
        ~results.cuda||...
        (strcmp(params.Hardware,'host')&&~results.hostcompiler)||...
        (~isempty(params.DeepLibTarget)&&~results.cudnn)||...
        (strcmp(params.DeepLibTarget,'tensorrt')&&~results.tensorrt)||...
        (params.DeepCodegen==1&&strcmp(params.DeepLibTarget,'tensorrt')&&results.tensorrt...
        &&results.gpu&&~results.tensorrtdatatype)||...
        (isprop(params,'Profiling')&&~checkParamResult(params.Profiling,results.profiling)))

        finalErrString='';
        for i=1:numel(checkGpuErrorList)
            if(isempty(finalErrString))
                finalErrString=checkGpuErrorList{i};
            else
                finalErrString=[finalErrString,newline,checkGpuErrorList{i}];%#ok<AGROW>
            end
        end
        error(message('gpucoder:system:gpu_sys_check',finalErrString));
    end
end


function[pf]=checkParamResult(param,result)
    pf=true;
    if(param==true)&&(result~=true)
        pf=false;
    end
end


function[checkGpuErrorList]=printStatus(headString,status,msgString,...
    installQuiet,checkGpuErrorList)
    headWidth=25;
    headString=char(headString);

    if(status)
        statusString=message('gpucoder:system:gpucodersetup_passed').getString;
    else
        statusString=message('gpucoder:system:gpucodersetup_failed').getString;
    end

    msgStringC=char(msgString);
    if(~isempty(msgStringC))
        msgStringC=['(',msgStringC,')'];
    end

    if(~installQuiet)
        spaces=headWidth-numel(headString);
        spaceStr=repmat(' ',[1,spaces]);
        fprintf('%s%s: %s %s\n',headString,spaceStr,statusString,msgStringC);
    else
        if(~status)
            errString=[headString,': ',msgStringC];
            if(isempty(checkGpuErrorList))
                checkGpuErrorList={errString};
            else
                checkGpuErrorList{end+1}=errString;
            end
        end
    end
end


function[checkGpuErrorList]=printSubStatus(headString,status,msgString,...
    installQuiet,checkGpuErrorList)
    headWidth=10;
    headString=char(headString);

    if(status)
        statusString=message('gpucoder:system:gpucodersetup_passed').getString;
    else
        statusString=message('gpucoder:system:gpucodersetup_failed').getString;
    end

    msgStringC=char(msgString);
    if(~isempty(msgStringC))
        msgStringC=['(',msgStringC,')'];
    end

    if(~installQuiet)
        spaces=headWidth-numel(headString);
        spaceStr=repmat(' ',[1,spaces]);
        fprintf('\t%s%s: %s %s\n',headString,spaceStr,statusString,msgStringC);
    else
        if(~status)
            errString=[headString,': ',msgStringC];
            if(isempty(checkGpuErrorList))
                checkGpuErrorList={errString};
            else
                checkGpuErrorList{end+1}=errString;
            end
        end
    end
end


function[xIn]=genTestData()
    xIn=rand(100,1);
end


function pf=checkResults(sim_out,codegen_out)
    diff=abs(sim_out-codegen_out);
    relDiff=diff./sim_out;
    pf=(relDiff>1e-5);
end


function[pf]=executeBoard(hwObj,buildDir,execTimeout,genReport)

    evalc('hwObj.runExecutable([buildDir ''/gpuSimpleTest.elf''])');
    outFile=[buildDir,'/output.bin'];
    pollExists(hwObj,outFile,execTimeout,genReport);

    log=strtrim(hwObj.system(['cat ',buildDir,'/gpuSimpleTest.log']));
    ignoreMsg=isa(hwObj,'drive')&&strcmpi(log,'nvrm_gpu: Bug 200215060 workaround enabled.');

    if isempty(log)||ignoreMsg

        xIn=(1:100)';
        sim_out=gpuSimpleTest(xIn);
        resizeVal=size(sim_out);
        outType=str2func(class(sim_out));


        hwObj.getFile(outFile);
        fid=fopen('output.bin','r');
        codegen_out=outType(fread(fid,numel(sim_out),class(sim_out)));
        codegen_out=reshape(codegen_out,resizeVal);
        fclose(fid);

        pf=checkResults(sim_out,codegen_out);
    else
        error('%s',log);
    end
end


function[pf]=executeDeepBoard(hwObj,buildDir,in,ntwkfile,execTimeout,genReport)

    hwObj.putFile('three_28x28.bin',buildDir);
    evalc('hwObj.runExecutable([buildDir ''/dlEntryPointTest.elf''], ''three_28x28.bin'')');
    outFile=[buildDir,'/tResult.bin'];
    pollExists(hwObj,outFile,execTimeout,genReport);

    log=strtrim(hwObj.system(['cat ',buildDir,'/dlEntryPointTest.log']));
    ignoreMsg=isa(hwObj,'drive')&&strcmpi(log,'nvrm_gpu: Bug 200215060 workaround enabled.');

    if isempty(log)||ignoreMsg

        sim_out=dlEntryPointTest(in,ntwkfile);
        resizeVal=size(sim_out);
        outType=str2func(class(sim_out));


        hwObj.getFile(outFile);
        fid=fopen('tResult.bin','r');
        codegen_out=outType(fread(fid,numel(sim_out),class(sim_out)));
        codegen_out=reshape(codegen_out,resizeVal);
        fclose(fid);
        pf=checkResults(sim_out,codegen_out);
    else
        error('%s',log);
    end
end


function[pf]=gpuFuncDriver()
    x=genTestData();
    sim_out=gpuSimpleTest(x);
    codegen_out=gpuSimpleTest_mex(x);
    pf=checkResults(sim_out,codegen_out);
end


function[pf]=executeDeep(in,ntwkfile)
    sim_out=dlEntryPointTest(in,ntwkfile);
    codegen_out=dlEntryPointTest_mex(in,ntwkfile);
    pf=checkResults(sim_out,codegen_out);
end


function[]=cleanupCodegen(cgDir)

    [~,~]=rmdir(cgDir);
end

function initializeReport(htmlFile,boardName,gpuName)

    cssFile=fullfile(matlabroot,'toolbox','gpucoder','gpucoder','checkGpuEnv.css');
    if ispc
        cssFile=replace(cssFile,filesep,[filesep,filesep]);
    end

    if isempty(boardName)
        boardName='Host GPU';
    else
        boardName=[boardName,' Board'];
        gpuName=[gpuName,' GPU'];
    end

    reportName=message('gpucoder:system:gpucodersetup_report_name').getString;
    resultsFor=message('gpucoder:system:gpucodersetup_report_gpuname',boardName,gpuName).getString;

    fprintf(htmlFile,'%s',['<!DOCTYPE html> <html> <head> <title>',reportName,'</title> ',...
    '<META http-equiv="Content-Type" content="text/html" charset="UTF-8">',...
    '<link href="',cssFile,'" rel="stylesheet" type="text/css"> </head>',...
    '<body> <h1> <div style="color:#004b87" align="center">',reportName,'</div> </h1>']);

    fprintf(htmlFile,'%s','<h2> <div style="color:#004b87" align="center">',resultsFor,'</div> </h2>');
    fprintf(htmlFile,'%s','<div style="height: 2px; background-color: #004b87"></div> <br><br>');

end

function printTableHeader(htmlFile,caption)
    caption=char(caption);
    colNames={message('gpucoder:system:table_colname_check').getString,...
    message('gpucoder:system:table_colname_result').getString,...
    message('gpucoder:system:table_colname_message').getString};

    fprintf(htmlFile,'%s',['<table class="table1">  <caption>',caption,'</caption> ',...
    '<thead> <tr> <th scope="col">',colNames{1},'</th> <th scope="col">',colNames{2},'</th> <th scope="col">',colNames{3},'</th> </tr> </thead> <tbody> ']);
end

function printTableFooter(htmlFile)

    fprintf(htmlFile,'%s','</tbody></table>');
end

function printBreaks(htmlFile)
    fprintf(htmlFile,'%s','<br><br>');
end


function printTableRow(htmlFile,headString,status,msgString)
    headString=char(headString);
    msgString=char(msgString);
    strStatus=getStatus(status);
    fprintf(htmlFile,'%s',['<tr> <td>',headString,'</td> <td><span class="',strStatus,'"></span></td> <td>',msgString,'</td> </tr>']);
end

function printEndOfReport(htmlFile)
    printBreaks(htmlFile);
    fprintf(htmlFile,'%s','</body> </html>');
end

function printSubTable(htmlFile,headString,hostStatus,msgString,libNames,libStatuses,subMsgString)
    headString=char(headString);
    msgString=char(msgString);
    hostStrStatus=getStatus(hostStatus);
    bullet={'a. ','b. ','c. ','d. '};

    fprintf(htmlFile,'%s',['<tr><td>',headString,'<br>']);
    fprintf(htmlFile,'%s','<table class="table2"> <br class="br1">');

    for i=1:4
        fprintf(htmlFile,'%s',['<tr><td>',bullet{i},libNames{i},' </td><td><span class="',getSubStatus(libStatuses(i)),'"></span></td> </tr>']);
    end
    printTableFooter(htmlFile);

    fprintf(htmlFile,'%s',['</td> <td><span class="',hostStrStatus,'"></span></td> <td>']);

    firstMsg=true;
    if~isempty(msgString)
        fprintf(htmlFile,'%s',msgString);
        firstMsg=false;
    end

    if(all(libStatuses))
        fprintf(htmlFile,'%s','</td></tr>');
    else
        for i=1:length(libStatuses)
            if~libStatuses(i)
                if~firstMsg
                    fprintf(htmlFile,'%s','<br>');
                end
                subMsg=char(subMsgString(i));
                fprintf(htmlFile,'%s',subMsg);
                firstMsg=false;
            end
        end
        fprintf(htmlFile,'%s','</td></tr>');
    end

end

function strStatus=getStatus(status)
    if(status)
        strStatus='pass';
    else
        strStatus='fail';
    end
end

function strStatus=getSubStatus(status)
    if(status)
        strStatus='pass_small';
    else
        strStatus='fail_small';
    end
end

function[cc,gpuName]=getBoardDetails(hwObj,gpuID)
    cc=num2str(hwObj.GPUInfo(gpuID+1).ComputeCapability);
    gpuName=hwObj.GPUInfo(gpuID+1).Name;
end

function disptarget=getDltargetDisp(dltarget)

    switch dltarget
    case 'cudnn'
        disptarget='cuDNN';
    case 'tensorrt'
        disptarget='TensorRT';
    end
end

function copyFilesToCurrDir(fileNames,srcPath)
    for idx=1:numel(fileNames)
        fullFileName=fullfile(srcPath,fileNames{idx});
        copyfile(fullFileName,'./');
    end
end

function pollExists(hwObj,outFile,execTimeout,genReport)
    pausetime=min(execTimeout,2);
    ret=1;
    ind=0;
    cmd=['[ -f ',outFile,' ] && echo "0" || echo "1"'];
    while(ret~=0&&ind<execTimeout)
        pause(pausetime);
        out=hwObj.system(cmd);
        ret=str2double(strtrim(out));
        ind=ind+pausetime;
    end

    if ret~=0
        if genReport
            error(message('gpucoder:system:timeout_board_exec_app'));
        else
            error(message('gpucoder:system:timeout_board_exec'));
        end
    end

end

function ret=isMatlabOnline()
    ret=matlab.internal.environment.context.isMATLABOnline||...
    matlab.ui.internal.desktop.isMOTW;
end
