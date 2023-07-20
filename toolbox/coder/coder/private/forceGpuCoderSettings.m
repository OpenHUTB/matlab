function forceGpuCoderSettings(cfg)





    setIfExists('ResponsivenessChecks',false);
    setIfExists('EnableAutoParallelization',true);
    if~exist('gpufeature','file')||~gpufeature('EnableMemcpy')
        setIfExists('EnableMemcpy',false);
    end
    setIfExists('EnableOpenMP',false);
    forceTargetLang();
    forceDeepLearningCfg();
    setIfExists('MultiInstanceCode',false);
    setIfExists('CppPreserveClasses',false);



    setIfExists('EnableSignedLeftShifts',true);
    setIfExists('EnableSignedRightShifts',true);



    setIfExists('IncludeInitializeFcn',true);
    setIfExists('IncludeTerminateFcn',true);

    forceSelectCudaDevice();
    if getProdEqTarget()
        forceProdLongLongMode();
    else
        forceTargetLongLongMode();
    end
    forceEmxArrayForUnifiedMode();
    forceEmxArrayForDynamicParallelism();


    setIfExists('InstructionSetExtensions','None');

    function setIfExists(propName,propValue)
        if isprop(cfg,propName)

            if strcmp(propName,'MultiInstanceCode')&&...
                propValue~=cfg.(propName)
                warning(message('gpucoder:common:MultiInstanceCodeUnsupported'));
            end

            if strcmp(propName,'CppPreserveClasses')&&...
                propValue~=cfg.(propName)
                warning(message('gpucoder:common:CppPreserveClassesUnsupported'));
            end
            cfg.(propName)=propValue;
        end
    end


    function forceSelectCudaDevice()
        if isa(cfg,'coder.MexCodeConfig')
            if isprop(cfg,'GpuConfig')&&isprop(cfg.GpuConfig,'SelectCudaDevice')
                cfg.GpuConfig.SelectCudaDevice=-1;
            end
        end
    end

    function prodEqTarget=getProdEqTarget()
        if isprop(cfg,'HardwareImplementation')&&isprop(cfg.HardwareImplementation,'ProdEqTarget')
            prodEqTarget=cfg.HardwareImplementation.ProdEqTarget;
        else
            prodEqTarget=false;
        end
    end

    function forceTargetLongLongMode()
        if isprop(cfg,'HardwareImplementation')&&isprop(cfg.HardwareImplementation,'TargetLongLongMode')
            cfg.HardwareImplementation.TargetLongLongMode=true;
            if~cfg.HardwareImplementation.TargetLongLongMode
                error(message('gpucoder:common:TargetDoesNotSupportLongLongMode'));
            end
        end
    end

    function forceProdLongLongMode()
        if isprop(cfg,'HardwareImplementation')&&isprop(cfg.HardwareImplementation,'ProdLongLongMode')
            cfg.HardwareImplementation.ProdLongLongMode=true;
            if~cfg.HardwareImplementation.ProdLongLongMode
                error(message('gpucoder:common:ProdDoesNotSupportLongLongMode'));
            end
        end
    end

    function forceEmxArrayForUnifiedMode()
        if isprop(cfg,'GpuConfig')&&isprop(cfg.GpuConfig,'MallocMode')&&...
            strcmpi(cfg.GpuConfig.MallocMode,'unified')
            setIfExists('DynamicMemoryAllocationInterface','C');
        end
    end

    function forceEmxArrayForDynamicParallelism()

        if isprop(cfg,'GpuConfig')&&isprop(cfg.GpuConfig,'MaxKernelDepth')&&...
            cfg.GpuConfig.MaxKernelDepth>0
            setIfExists('DynamicMemoryAllocationInterface','C');
        end
    end

    function forceTargetLang()
        if~isprop(cfg,'GpuConfig')||isempty(cfg.GpuConfig)
            return;
        end
        if cfg.GpuConfig.isCUDACodegen()
            setIfExists('TargetLang','C++');
        elseif cfg.GpuConfig.isOpenCLCodegen()
            setIfExists('TargetLang','C');
        end
    end

    function forceDeepLearningCfg()
        if isprop(cfg,'GpuConfig')&&~isempty(cfg.GpuConfig)&&cfg.GpuConfig.isOpenCLCodegen()
            setIfExists('DeepLearningConfig',coder.DeepLearningConfigBase.empty());
        end
    end
end
