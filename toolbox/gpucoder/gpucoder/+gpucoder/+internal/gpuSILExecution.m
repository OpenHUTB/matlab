function[silProfileResults,codegenReturnValue]=gpuSILExecution(funcName,numIterations,compiletimeInputs,...
    runtimeInputs,gpuConfigOptions,cfg,codegenArgsInput,profilerFlags)






    if isempty(cfg.Hardware)
        cfg.GpuConfig.ComputeCapability=gpucoder.internal.getBestComputeCapability();
    else


        nvobj=nvidiaboard(cfg.Hardware.DeviceAddress,...
        cfg.Hardware.Username,cfg.Hardware.Password);


        userIsSudoer=true;%#ok<NASGU>
        userIsSudoer=nvidiacoder.internal.isUserSudoer(nvobj);
        if~userIsSudoer
            error(message('nvidia:utils:UserNotSudoer'));
        end



        targetGpuDevice=cfg.GpuConfig.SelectCudaDevice;


        gpuInfo=nvobj.getGpuInfo();
        targetNumCudaDevices=length(gpuInfo);



        if(targetGpuDevice<0)||(targetNumCudaDevices<=targetGpuDevice)
            targetGpuDevice=0;
        end


        targetGpuCC=gpuInfo(targetGpuDevice+1).ComputeCapability;
        cfg.GpuConfig.ComputeCapability=num2str(targetGpuCC);
    end

    cfg.GpuConfig=applyCustomConfiguration(cfg.GpuConfig,gpuConfigOptions);

    cfg.GenerateReport=1;


    if isempty(codegenArgsInput)
        codegenArgs={'-config',cfg,'-args',compiletimeInputs};%#ok<NASGU>
    else
        AdditionalArgs=strsplit(codegenArgsInput);
        codegenArgs={'-config',cfg,'-args',compiletimeInputs,AdditionalArgs{:}};%#ok<NASGU>

    end
    [~,funcName,~]=fileparts(funcName);


    codegenReturnValue=codegen(funcName,codegenArgs{:});



    if~isfield(codegenReturnValue,'summary')||(~codegenReturnValue.summary.passed)
        errString='';
        if isfield(codegenReturnValue,'summary')
            for idx=1:length(codegenReturnValue.summary.messageList)
                errString=[codegenReturnValue.summary.messageList{idx}.MsgText,newline];
            end
            error(message('gpucoder:profile:sil_gen_failure',...
            [newline,errString]));
        else
            error(message('gpucoder:profile:sil_gen_failure',...
            codegenReturnValue.internal.message));
        end
    end


    if~isempty(cfg.Hardware)
        mexName=[funcName,'_pil'];
    else
        mexName=[funcName,'_sil'];
    end

    gpucoder.internal.executeGPUSILProfiling(mexName,numIterations,runtimeInputs);
    silProfileResults=getCoderExecutionProfile(funcName);


    if isa(silProfileResults,'coder.profile.GpuExecutionTime')
        silProfileResults=coder.profile.GpuExecutionTime.addGPUProfilingData(silProfileResults,numIterations,profilerFlags,cfg.Hardware);
    end
end

function gpuCfg=applyCustomConfiguration(gpuCfg,ccoptions)
    if~isempty(ccoptions)
        if mod(length(ccoptions),2)==0
            for i=1:2:length(ccoptions)
                gpuCfg.(ccoptions{i})=ccoptions{i+1};
            end
        else
            error('Incorrect number of gpu config params');
        end
    end
end