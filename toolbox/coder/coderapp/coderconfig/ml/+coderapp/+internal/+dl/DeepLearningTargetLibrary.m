classdef(Sealed)DeepLearningTargetLibrary<coderapp.internal.config.util.EnumOptionSource


    enumeration
        None('none','coderApp:config:deepLearning:targetLibNone')
        MKLDNN('mkldnn','coderApp:config:deepLearning:targetLibMKLDNN')
        cuDNN('cudnn','coderApp:config:deepLearning:targetLibCuDNN')
        TensorRT('tensorrt','coderApp:config:deepLearning:targetLibTensorRT')
        ArmCompute('arm-compute','coderApp:config:deepLearning:targetLibArmCompute')
        CMSISNN('cmsis-nn','coderApp:config:deepLearning:targetLibCMSISNN')
    end

    methods
        function dlCfg=newConfig(this)
            dlCfg=coder.DeepLearningConfig(this.Option.Value);
        end
    end
end