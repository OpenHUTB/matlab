function mustBeSupportedPlatformForMex(gpuShouldBeUsed)






    if ismac
        error(message('nnet_cnn:dlAccel:UnsupportedPlatform','Mac'));
    end

    if isdeployed

        error(message('nnet_cnn:dlAccel:UnsupportedInDeployedApplication'));
    end

    if gpuShouldBeUsed
        if~dlcoder_base.internal.isGpuCoderDLTargetsInstalled

            spkgName='GPU Coder Interface for Deep Learning Libraries';
            spkgbasecode='GPU_DEEPLEARNING_LIB';
            error(message('gpucoder:cnncodegen:missing_support_package','cudnn',spkgName,spkgbasecode));
        end
    else

        error(message('nnet_cnn:dlAccel:CPUIsNotSupported'));
    end
end