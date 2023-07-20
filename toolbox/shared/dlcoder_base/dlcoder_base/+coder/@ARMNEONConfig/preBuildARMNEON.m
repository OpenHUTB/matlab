




function preBuildARMNEON(obj,codeConfig)




    if(strcmpi(obj.DataType,'int8'))
        obj.OptimizationConfig.HorizontalConvFusion=false;
        obj.OptimizationConfig.StrideOptimization=false;
        obj.OptimizationConfig.RNNLayerFusion=false;


        obj.OptimizationConfig.ConvClippedReLUFusion=false;
        obj.OptimizationConfig.ConvTanhFusion=false;
        obj.OptimizationConfig.ConvSigmoidFusion=false;
        obj.OptimizationConfig.ConvLeakyReLUFusion=false;
        obj.OptimizationConfig.ConvELUFusion=false;

        obj.OptimizationConfig.ConvAddReLUFusion=false;
        obj.OptimizationConfig.ConvAddClippedReLUFusion=false;
        obj.OptimizationConfig.ConvAddLeakyReLUFusion=false;
        obj.OptimizationConfig.ConvAddTanhFusion=false;
        obj.OptimizationConfig.ConvAddELUFusion=false;
        obj.OptimizationConfig.ConvAddSigmoidFusion=false;

    end

    if isa(codeConfig,'coder.MexCodeConfig')
        error(message('gpucoder:cnnconfig:UnsupportedConfigurationObject'));
    end



    dlcoder_base.internal.checkForSupportPackages('arm-compute');

    dlCroscompilersRegistry=dltargets.arm_neon.DLCrosscompilersRegistry;
    isCrossCompile=dlCroscompilersRegistry.isSupportedCrossCompilerToolChain(codeConfig.Toolchain);

    if isCrossCompile
        dltargets.arm_neon.dlValidateCrossCompile(dlCroscompilersRegistry,codeConfig);
    else
        dltargets.arm_neon.dlValidateHWNativeBuild(codeConfig);
    end

    if isempty(codeConfig.Hardware)&&strcmp(codeConfig.HardwareImplementation.ProdHWDeviceType,'Generic->MATLAB Host Computer')
        if strcmp(codeConfig.DeepLearningConfig.ArmArchitecture,'armv8')
            codeConfig.HardwareImplementation.ProdHWDeviceType='ARM Compatible->ARM 64-bit (LP64)';
        else
            codeConfig.HardwareImplementation.ProdHWDeviceType='ARM Compatible->ARM Cortex';
        end
    end


end
