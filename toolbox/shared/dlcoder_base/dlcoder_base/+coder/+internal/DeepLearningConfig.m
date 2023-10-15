function deepLearningCfg = DeepLearningConfig( targetLib, nvps )

arguments
    targetLib( 1, 1 )string = "none"
    nvps.DeepLearningAcceleration( 1, 1 )logical = false
    nvps.TargetLibrary( 1, 1 )string
end

dlMexAcceleration = nvps.DeepLearningAcceleration;

if ( nargin == 1 ) && isfield( nvps, 'TargetLibrary' )

    error( message( 'gpucoder:cnnconfig:InvalidInputForDeepLearningConfig' ) );
end

if isfield( nvps, 'TargetLibrary' )
    targetLib = lower( nvps.TargetLibrary );
else
    targetLib = lower( targetLib );
end

dlcoder_base.internal.checkSupportedTargetLib( targetLib, dlMexAcceleration );

switch targetLib

    case 'cudnn'

        deepLearningCfg = coder.CuDNNConfig(  );


        if ~license( 'test', 'GPU_Coder' ) && ~dlMexAcceleration
            warning( message( 'gpucoder:cnnconfig:MissingGpuCoderLicense', targetLib ) );
        end

    case 'tensorrt'

        deepLearningCfg = coder.TensorRTConfig(  );

        if ~license( 'test', 'GPU_Coder' ) && ~dlMexAcceleration
            warning( message( 'gpucoder:cnnconfig:MissingGpuCoderLicense', targetLib ) );
        end

    case 'mkldnn'

        deepLearningCfg = coder.MklDNNConfig(  );

    case 'onednn'

        deepLearningCfg = coder.OneDNNConfig(  );

    case 'arm-compute'

        deepLearningCfg = coder.ARMNEONConfig(  );

    case 'arm-compute-mali'

        deepLearningCfg = coder.ARMMALIConfig(  );

    case 'none'

        deepLearningCfg = coder.DeepLearningConfigBase(  );


    case 'cmsis-nn'

        deepLearningCfg = coder.CMSISNNConfig(  );
    otherwise

        assert( false );
end

end

