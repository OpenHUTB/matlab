




function preBuildCMSISNN(obj,codeConfig)

    if isa(codeConfig,'coder.MexCodeConfig')
        error(message('gpucoder:cnnconfig:UnsupportedCmsisnnConfigOption'));
    end

    if strcmpi(codeConfig.TargetLang,'C++')
        error(message('gpucoder:cnnconfig:UnsupportedCmsisnnBuildType'));
    end



    dlcoder_base.internal.checkForSupportPackages('cmsis-nn');



    if strcmpi(codeConfig.DeepLearningConfig.TargetLibrary,'cmsis-nn')
        if isempty(codeConfig.DeepLearningConfig.CalibrationResultFile)
            error(message('gpucoder:cnnconfig:EmptyCalibrationResultFile'));
        end
    end

end


