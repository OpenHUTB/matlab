



function preBuild(this,codeConfig)



    if any(strcmpi(this.TargetLibrary,{'tensorrt','cudnn'}))
        if isempty(codeConfig.GpuConfig)


            warning(message('gpucoder:cnnconfig:MissingGpuConfig',this.TargetLibrary));
            if~exist('coder.GpuCodeConfig','class')
                error(message('gpucoder:cnnconfig:GpuCoderNotInstalled',this.TargetLibrary));
            end
            tempcg=coder.gpuConfig;
            codeConfig.GpuConfig=tempcg.GpuConfig;
            codeConfig.GpuConfig.Enabled=true;

        elseif~codeConfig.GpuConfig.Enabled

            warning(message('gpucoder:cnnconfig:MissingGpuConfig',this.TargetLibrary));
            codeConfig.GpuConfig.Enabled=true;
        end

    end

    targetsSupportedForC=["none","cmsis-nn"];


    if~strcmpi(codeConfig.TargetLang,'C++')&&...
        ~any(strcmp(this.TargetLibrary,targetsSupportedForC))
        warning(message('gpucoder:cnnconfig:MissingCppTarget',this.TargetLibrary));
        codeConfig.TargetLang='C++';
    end

    if strcmpi(this.TargetLibrary,'arm-compute')
        codeConfig.DeepLearningConfig.preBuildARMNEON(codeConfig);
    end


    if isa(codeConfig.DeepLearningConfig,'coder.CuDNNConfig')
        codeConfig.DeepLearningConfig.preBuildCuDNN();
    end


    if isa(codeConfig.DeepLearningConfig,'coder.MklDNNConfig')
        codeConfig.DeepLearningConfig.preBuildMklDNN(codeConfig);
    end


    if isa(codeConfig.DeepLearningConfig,'coder.OneDNNConfig')
        codeConfig.DeepLearningConfig.preBuildOneDNN(codeConfig);
    end


    if isa(codeConfig.DeepLearningConfig,'coder.CMSISNNConfig')
        codeConfig.DeepLearningConfig.preBuildCMSISNN(codeConfig);
    end
end


