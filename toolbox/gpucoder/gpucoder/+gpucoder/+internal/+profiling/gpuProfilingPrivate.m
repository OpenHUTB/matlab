function etStruct=gpuProfilingPrivate(funcName,compiletimeInputs,varargin)%#ok<*INUSL>




    try

        if~license('test','rtw_embedded_coder')
            error(message('gpucoder:profile:no_embedded_coder'));
        end

        [gpuConfigOptions,numIterations,cfg,codegenArgs,profilerFlags]=validateArgs(funcName,varargin{:});
        runtimeInputs=gpucoder.internal.profiling.genRuntimeInputsFromCodegenInputs(compiletimeInputs);


        if(ispc&&isempty(cfg.Hardware))
            [profilingStatus,msg]=coder.internal.checkProfilingEnvironment;
            if~profilingStatus
                error(msg);
            end
            oldPath=getenv('PATH');
            setenv('PATH',[oldPath,';',getenv('NVTOOLSEXT_PATH'),'bin\x64']);
        end

        if(numIterations==1)
            profilerFlags.excludeFirst=false;
        end

        etStruct=gpucoder.internal.gpuSILExecution(funcName,numIterations,compiletimeInputs,...
        runtimeInputs,gpuConfigOptions,cfg,codegenArgs,profilerFlags);
        p=profile('info');

        if~isempty(cfg.Hardware)
            etStruct.TimerTicksPerSecond=1000000000;
        else
            etStruct.TimerTicksPerSecond=p.ClockSpeed;
        end

        report(etStruct,'Units','Seconds','ScaleFactor','1e-3','NumericFormat','%5.5f');

        if ispc&&exist('oldPath','var')
            setenv('PATH',oldPath);
        end

    catch e
        if ispc&&exist('oldPath','var')
            setenv('PATH',oldPath);
        end
        throw(e);
    end

end

function[gpuConfigOptions,numCalls,cfgCopy,codegenArgs,profileFlags]=validateArgs(funcName,varargin)
    iParser=inputParser();


    configValidationFcn=@(lf)validateattributes(lf,{'coder.EmbeddedCodeConfig'},{'nonempty'});

    addParameter(iParser,'CodegenConfig',coder.gpuConfig('dll'),configValidationFcn);

    codegenArgsValidationFcn=@(lf)validateattributes(lf,{'char'},{'nonempty'});
    addParameter(iParser,'CodegenArguments','',codegenArgsValidationFcn);

    addParameter(iParser,'NumCalls',6,@(x)validateattributes(x,{'numeric'},{'scalar','>',0,'integer'}));
    addParameter(iParser,'Threshold',0,@(x)validateattributes(x,{'numeric'},{'scalar','>=',0}));

    profileModeValidationFcn=@(lf)validateattributes(lf,{'char'},{'nonempty'});
    addParameter(iParser,'ProfilingMode','excludeFirst',profileModeValidationFcn);
    addParameter(iParser,'ShowCompleteTrace',false,@(x)validateattributes(x,{'logical'}));

    addParameter(iParser,'GpuConfigurationOptions',cell.empty);

    iParser.parse(varargin{:});

    gpuConfigOptions=iParser.Results.GpuConfigurationOptions;
    profMode=iParser.Results.ProfilingMode;
    numCalls=iParser.Results.NumCalls;
    codegenArgs=iParser.Results.CodegenArguments;

    cfg=iParser.Results.CodegenConfig;


    cfgCopy=cfg.copy();

    profilingHardware=~isempty(cfgCopy.Hardware);
    if profilingHardware
        validateTargetHardware(cfgCopy);
        cfgCopy.VerificationMode='PIL';
    else

        cfgCopy.VerificationMode='SIL';
    end


    cfgCopy.CodeExecutionProfiling=1;
    if isempty(cfgCopy.GpuConfig)
        error(message('gpucoder:profile:no_gpuconfig'));
    end

    cfgCopy.GpuConfig.AddnvtxInstrumentation=1;
    cfgCopy.GpuConfig.EnableGPUSILProfiling=1;

    if~strcmp('CodegenConfig',iParser.UsingDefaults)
        if isempty(cfgCopy.Hardware)
            cfgCopy.OutputType='DLL';
        else
            cfgCopy.OutputType='LIB';
        end
    end

    excludeFirstFlag=true;
    profMode_exclude_Options=[strcmp(profMode,'excludeFirst'),strcmp(profMode,'ExcludeFirst'),...
    strcmp(profMode,'excludefirst'),strcmp(profMode,'exclude First'),strcmp(profMode,'Exclude First')];

    profMode_all_Options=[strcmp(profMode,'all'),strcmp(profMode,'All'),strcmp(profMode,'ALL')];
    if~any(profMode_exclude_Options)&&any(profMode_all_Options)
        excludeFirstFlag=false;
    end

    showCompleteTraceFlag=iParser.Results.ShowCompleteTrace;
    threshold=iParser.Results.Threshold*1e3;

    profileFlags.excludeFirst=excludeFirstFlag;
    profileFlags.showCompleteTrace=showCompleteTraceFlag;
    profileFlags.threshold=threshold;
end

function validateTargetHardware(cfg)

    hFlag=contains(cfg.Hardware.Name,'NVIDIA Jetson')||...
    contains(cfg.Hardware.Name,'NVIDIA Drive');


    if~hFlag
        error(message('nvidia:utils:ProfInvalidHardware'));
    end


    if~strcmpi(cfg.OutputType,'lib')
        error(message('nvidia:utils:ProfInvalidCoderTarget'));
    end


    if(ispc)
        [status,~]=system(['ping -n 4 ',cfg.Hardware.DeviceAddress]);
    else
        [status,~]=system(['ping -c 4 ',cfg.Hardware.DeviceAddress]);
    end

    if status
        error(message('nvidia:utils:ProfHardwareNotAvailable'));
    end

end
