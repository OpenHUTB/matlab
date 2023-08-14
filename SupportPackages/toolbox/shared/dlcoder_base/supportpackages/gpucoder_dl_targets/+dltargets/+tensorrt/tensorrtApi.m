classdef tensorrtApi<coder.ExternalDependency&coder.internal.JITSupportedExternalDependency






%#codegen
    methods(Static)
        function bName=getDescriptiveName(~)
            bName='tensorrtApi';
        end

        function tf=isSupportedContext(ctx)
            config=coder.internal.getDeepLearningConfig(ctx);

            if isa(config,'coder.TensorRTConfig')
                tf=true;
                return;
            end

            tf=false;
        end


        function addShippingLibDeps(buildInfo,ctx)
            assert(ctx.isCodeGenTarget('mex')||ctx.isCodeGenTarget('sfun'));

            if isunix


                LibDir=fullfile(matlabroot,'bin','glnxa64');
                cudnnFile=coder.gpu.internal.getShippingLibFullName('libcudnn',LibDir);
                assert(~isempty(cudnnFile),'libcudnn not found');
                buildInfo.addSysLibs([':',cudnnFile],LibDir);


                nvinferFile=coder.gpu.internal.getShippingLibFullName('libnvinfer',LibDir);
                assert(~isempty(nvinferFile),'libnvinfer not found');
                buildInfo.addSysLibs([':',nvinferFile],LibDir);


                cudartFile=coder.gpu.internal.getShippingLibFullName('libcudart',LibDir);
                assert(~isempty(cudartFile),'libcudart not found');
                buildInfo.addSysLibs([':',cudartFile],LibDir);


                cudnnIncludeDir=fullfile(matlabroot,'sys/cuda/glnxa64/cudnn/include');
                tensorrtIncludeDir=fullfile(matlabroot,'sys/cuda/glnxa64/tensorrt/include');
                buildInfo.addCompileFlags('-std=c++11','CU_OPTS');






                buildInfo.addCompileFlags('-Wno-deprecated-declarations','CU_OPTS');
            elseif ispc


                cudnnLibDir=fullfile(matlabroot,'sys/cuda/win64/cudnn/lib/x64');
                libPriority='';
                libPreCompiled=true;
                libLinkOnly=true;
                [~,linkLibExt,~,~]=ctx.getStdLibInfo();
                libName=strcat('cudnn',linkLibExt);
                buildInfo.addLinkObjects(libName,cudnnLibDir,...
                libPriority,libPreCompiled,libLinkOnly);

                tensorrtLibDir=fullfile(matlabroot,'sys/cuda/win64/tensorrt/lib/x64');


                libName=strcat('nvinfer',linkLibExt);
                buildInfo.addLinkObjects(libName,tensorrtLibDir,...
                libPriority,libPreCompiled,libLinkOnly);


                cudalibDir=fullfile(matlabroot,'sys/cuda/win64/cuda/lib/x64');
                libName=strcat('cudart',linkLibExt);
                buildInfo.addLinkObjects(libName,cudalibDir,...
                libPriority,libPreCompiled,libLinkOnly);


                cudnnIncludeDir=fullfile(matlabroot,'sys/cuda/win64/cudnn/include');
                tensorrtIncludeDir=fullfile(matlabroot,'sys/cuda/win64/tensorrt/include');

            else
                assert(false,'TensorRT is not supported on Mac');
            end

            buildInfo.addIncludePaths(cudnnIncludeDir);
            buildInfo.addIncludePaths(tensorrtIncludeDir);
        end



        function addPrecompiledTargetLibraryDeps(buildInfo,ctx)
            assert(ctx.isCodeGenTarget('mex')||dltargets.tensorrt.tensorrtApi.inSimulinkSimulationMode(ctx),...
            'Precompiled layer libraries should only be used for MEX or Simulink simulation workflows.');

            if ispc
                matlabLibDir=fullfile(matlabroot,'lib','win64');


                libPriority='';
                libPreCompiled=true;
                libLinkOnly=true;
                [~,linkLibExt,~,~]=ctx.getStdLibInfo();
                buildInfo.addLinkObjects(strcat('shared_layers',linkLibExt),matlabLibDir,...
                libPriority,libPreCompiled,libLinkOnly);
                buildInfo.addLinkObjects(strcat('cudnn_layers',linkLibExt),matlabLibDir,...
                libPriority,libPreCompiled,libLinkOnly);
                buildInfo.addLinkObjects(strcat('tensorrt_layers',linkLibExt),matlabLibDir,...
                libPriority,libPreCompiled,libLinkOnly);





                layerHeaderIncludeDir=fullfile(matlabroot,'derived','win64','src','include','layer');
                cudnnLayerImplHeaderIncludeDir=fullfile(matlabroot,'derived','win64','src','include','cudnn');
                tensorrtLayerImplHeaderIncludeDir=fullfile(matlabroot,'derived','win64','src','include','tensorrt');
            else
                matlabLibDir=fullfile(matlabroot,'bin','glnxa64');


                buildInfo.addSysLibs('mwshared_layers',matlabLibDir);
                buildInfo.addSysLibs('mwcudnn_layers',matlabLibDir);
                buildInfo.addSysLibs('mwtensorrt_layers',matlabLibDir);

                linkFlags=strcat('-Xlinker -rpath,',matlabLibDir);
                buildInfo.addLinkFlags(linkFlags);





                layerHeaderIncludeDir=fullfile(matlabroot,'derived','glnxa64','src','include','layer');
                cudnnLayerImplHeaderIncludeDir=fullfile(matlabroot,'derived','glnxa64','src','include','cudnn');
                tensorrtLayerImplHeaderIncludeDir=fullfile(matlabroot,'derived','glnxa64','src','include','tensorrt');
            end

            buildInfo.addIncludePaths(layerHeaderIncludeDir);
            buildInfo.addIncludePaths(cudnnLayerImplHeaderIncludeDir);
            buildInfo.addIncludePaths(tensorrtLayerImplHeaderIncludeDir);


        end

        function updateBuildInfoForUserLibs(buildInfo,ctx)

            dltargets.tensorrt.tensorrtApi.addFlagstoAllowTRTV8x(buildInfo);
            [~,linkLibExt,~,~]=ctx.getStdLibInfo();
            tensorrtBase=getenv('NVIDIA_TENSORRT');
            if isunix



                if(exist(fullfile(tensorrtBase,'lib64','libnvinfer.so'),'file')==2)
                    tensorrtLibDir=fullfile(tensorrtBase,'lib64');
                else
                    tensorrtLibDir=fullfile(tensorrtBase,'lib');
                end
                cudnnLibDir=fullfile(getenv('NVIDIA_CUDNN'),'lib64');
                buildInfo.addSysLibs('cudnn',cudnnLibDir);
                buildInfo.addSysLibs('nvinfer',tensorrtLibDir);

                buildInfo.addSysLibs('cudart');
                buildInfo.addCompileFlags('-std=c++11','CU_OPTS');

                linkFlags=strcat('-Xlinker -rpath,',cudnnLibDir);
                buildInfo.addLinkFlags(linkFlags);

                linkFlags=strcat('-Xlinker -rpath,',tensorrtLibDir);
                buildInfo.addLinkFlags(linkFlags);

            elseif ispc


                if(exist(fullfile(tensorrtBase,'lib','x64','nvinfer.lib'),'file')==2)
                    tensorrtLibDir=fullfile(tensorrtBase,'lib','x64');
                else
                    tensorrtLibDir=fullfile(tensorrtBase,'lib');
                end

                cudnnLibDir=fullfile(getenv('NVIDIA_CUDNN'),'lib','x64');

                libPriority='';
                libPreCompiled=true;
                libLinkOnly=true;
                libName=strcat('cudnn',linkLibExt);
                buildInfo.addLinkObjects(libName,cudnnLibDir,...
                libPriority,libPreCompiled,libLinkOnly);
                buildInfo.addLinkObjects(libName,tensorrtLibDir,...
                libPriority,libPreCompiled,libLinkOnly);
                libName=strcat('nvinfer',linkLibExt);
                buildInfo.addLinkObjects(libName,tensorrtLibDir,...
                libPriority,libPreCompiled,libLinkOnly);

                cudalibDir=fullfile(getenv('CUDA_PATH'),'lib','x64');
                libName=strcat('cudart',linkLibExt);
                buildInfo.addLinkObjects(libName,cudalibDir,...
                libPriority,libPreCompiled,libLinkOnly);
            end


            cudnnIncludeDir=fullfile(getenv('NVIDIA_CUDNN'),'include');
            buildInfo.addIncludePaths(cudnnIncludeDir);


            tensorrtIncludeDir=fullfile(getenv('NVIDIA_TENSORRT'),'include');
            buildInfo.addIncludePaths(tensorrtIncludeDir);




            buildInfo.addCompileFlags('-Wno-deprecated-declarations','CU_OPTS');

        end

        function updateBuildInfoForEmbeddedTarget(buildInfo)

            dltargets.tensorrt.tensorrtApi.addFlagstoAllowTRTV8x(buildInfo);
            buildInfo.addLinkFlags('-lcudnn');
            buildInfo.addLinkFlags('-lnvinfer');
            buildInfo.addLinkFlags('-lcudart');


            buildInfo.addCompileFlags('-std=c++11','CU_OPTS');




            buildInfo.addCompileFlags('-Wno-deprecated-declarations','CU_OPTS');


        end

        function updateBuildInfoForCrossCompileWorkflow(buildInfo)

            dltargets.tensorrt.tensorrtApi.addFlagstoAllowTRTV8x(buildInfo);
            buildInfo.addLinkFlags('-lcudnn');
            buildInfo.addLinkFlags('-lnvinfer');
            buildInfo.addLinkFlags('-lcudart');


            cudnnIncludeDir=fullfile(getenv('NVIDIA_CUDNN'),'include');
            buildInfo.addIncludePaths(cudnnIncludeDir);


            tensorrtIncludeDir=fullfile(getenv('NVIDIA_TENSORRT'),'include');
            buildInfo.addIncludePaths(tensorrtIncludeDir);


            buildInfo.addCompileFlags('-std=c++11','CU_OPTS');




            buildInfo.addCompileFlags('-Wno-deprecated-declarations','CU_OPTS');

        end

        function simulinkContext=inSimulinkContext(ctx)
            simulinkContext=isa(ctx.ConfigData,'Simulink.ConfigSet');
        end


        function simulinkSimulationMode=inSimulinkSimulationMode(ctx)
            simulinkSimulationMode=strcmp(ctx.CodeGenTarget,'sfun')&&isa(ctx.ConfigData,'Simulink.ConfigSet');
        end


        function simulinkCodegenMode=inSimulinkCodegenMode(ctx)
            simulinkCodegenMode=strcmp(ctx.CodeGenTarget,'rtw')&&isa(ctx.ConfigData,'Simulink.ConfigSet');
        end

        function GpuEnabled=isGpuCoderEnabled(ctx)
            enableGpuCoderSim=ctx.getConfigProp('GPUAcceleration');
            enableGpuCoderCodegen=ctx.getConfigProp('GenerateGPUCode');
            GpuEnabled=strcmpi(enableGpuCoderSim,'on')||strcmpi(enableGpuCoderCodegen,'CUDA');
        end

        function mexOrStandaloneTarget=isMexOrStandaloneTarget(ctx)
            mexOrStandaloneTarget=ctx.isCodeGenTarget('mex')||~coder.gpu.internal.isEmbeddedTarget(ctx);
        end


        function addFlagstoAllowTRTV8x(buildInfo)
            if dlcoderfeature('AllowTensorRTV8X')
                buildInfo.addCompileFlags('-DALLOW_TENSORRT_8X=1','CU_OPTS');
            end
        end







        function updateBuildInfo(buildInfo,ctx)


            isHSPTarget=coder.gpu.internal.isEmbeddedTarget(ctx);

            if dltargets.tensorrt.tensorrtApi.inSimulinkContext(ctx)

                if dltargets.tensorrt.tensorrtApi.inSimulinkSimulationMode(ctx)


                    assert(~isHSPTarget);
                    dltargets.tensorrt.tensorrtApi.addShippingLibDeps(buildInfo,ctx);

                    dltargets.tensorrt.tensorrtApi.addPrecompiledTargetLibraryDeps(buildInfo,ctx);

                elseif dltargets.tensorrt.tensorrtApi.inSimulinkCodegenMode(ctx)&&~isHSPTarget


                    dltargets.tensorrt.tensorrtApi.updateBuildInfoForUserLibs(buildInfo,ctx);


                else


                    assert(dltargets.tensorrt.tensorrtApi.inSimulinkCodegenMode(ctx)&&isHSPTarget);
                    dltargets.tensorrt.tensorrtApi.updateBuildInfoForEmbeddedTarget(buildInfo);
                end

            else


                config=ctx.getConfigProp('GpuConfig');
                assert(isa(config,'coder.GpuCodeConfig'));
                toolchainName=ctx.getConfigProp('Toolchain');

                if config.UseShippingLibs


                    assert(ctx.isCodeGenTarget('mex'),'UseShippingLibs is only supported for MEX target');
                    dltargets.tensorrt.tensorrtApi.addShippingLibDeps(buildInfo,ctx);



                elseif dltargets.tensorrt.tensorrtApi.isMexOrStandaloneTarget(ctx)

                    dltargets.tensorrt.tensorrtApi.updateBuildInfoForUserLibs(buildInfo,ctx);


                elseif contains(toolchainName,'NVIDIA CUDA for Jetson Tegra K1 v6.5 | gmake (64-bit Linux)')...
                    ||contains(toolchainName,'NVIDIA CUDA for Jetson Tegra X1 | gmake (64-bit Linux)')...
                    ||contains(toolchainName,'NVIDIA CUDA for Jetson Tegra X2 | gmake (64-bit Linux)')

                    dltargets.tensorrt.tensorrtApi.updateBuildInfoForCrossCompileWorkflow(buildInfo);


                elseif contains(toolchainName,'NVCC for NVIDIA Embedded Processors')


                    assert(isHSPTarget);
                    dltargets.tensorrt.tensorrtApi.updateBuildInfoForEmbeddedTarget(buildInfo);


                end

            end

            dlConfig=coder.internal.getDeepLearningConfig(ctx);

            assert(isa(dlConfig,'coder.TensorRTConfig'));

            if dlConfig.EnableDebugging
                buildInfo.addDefines('DEBUG=1');
            end

            if strcmpi(dlConfig.CalibrationAlgorithm,'IInt8MinMaxCalibrator')
                buildInfo.addDefines('MINMAXCALIBRATOR=1');
            end

            if ctx.isCodeGenTarget('mex')
                dltargets.tensorrt.tensorrtApi.addPrecompiledTargetLibraryDeps(buildInfo,ctx);
            end

        end



        function register()
            coder.inline('always');
            coder.allowpcode('plain');
        end

    end

end

