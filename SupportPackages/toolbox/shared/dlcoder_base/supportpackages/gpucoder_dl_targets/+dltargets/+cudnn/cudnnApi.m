
classdef cudnnApi<coder.ExternalDependency&coder.internal.JITSupportedExternalDependency





%#codegen
    methods(Static)
        function bName=getDescriptiveName(~)
            bName='cudnnApi';
        end

        function tf=isSupportedContext(ctx)
            config=coder.internal.getDeepLearningConfig(ctx);
            if isa(config,'coder.CuDNNConfig')
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

                cublasFile=coder.gpu.internal.getShippingLibFullName('libcublas',LibDir);
                assert(~isempty(cublasFile),'libcublas not found');
                buildInfo.addSysLibs([':',cublasFile],LibDir);
                cudnnIncludeDir=fullfile(matlabroot,'sys/cuda/glnxa64/cudnn/include');
            elseif ispc
                cudnnLibDir=fullfile(matlabroot,'sys/cuda/win64/cudnn/lib/x64');
                libPriority='';
                libPreCompiled=true;
                libLinkOnly=true;
                [~,linkLibExt,~,~]=ctx.getStdLibInfo();
                libName=strcat('cudnn',linkLibExt);
                buildInfo.addLinkObjects(libName,cudnnLibDir,...
                libPriority,libPreCompiled,libLinkOnly);
                cudnnIncludeDir=fullfile(matlabroot,'sys/cuda/win64/cudnn/include');
            end
            buildInfo.addIncludePaths(cudnnIncludeDir);
        end



        function addPrecompiledTargetLibraryDeps(buildInfo,ctx)
            assert(ctx.isCodeGenTarget('mex')||dltargets.cudnn.cudnnApi.inSimulinkSimulationMode(ctx),...
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


                layerHeaderIncludeDir=fullfile(matlabroot,'derived','win64','src','include','layer');
                layerImplHeaderIncludeDir=fullfile(matlabroot,'derived','win64','src','include','cudnn');
            else
                matlabLibDir=fullfile(matlabroot,'bin','glnxa64');


                buildInfo.addSysLibs('mwshared_layers',matlabLibDir);
                buildInfo.addSysLibs('mwcudnn_layers',matlabLibDir);

                linkFlags=strcat('-Xlinker -rpath,',matlabLibDir);
                buildInfo.addLinkFlags(linkFlags);


                layerHeaderIncludeDir=fullfile(matlabroot,'derived','glnxa64','src','include','layer');
                layerImplHeaderIncludeDir=fullfile(matlabroot,'derived','glnxa64','src','include','cudnn');
            end

            buildInfo.addIncludePaths(layerHeaderIncludeDir);
            buildInfo.addIncludePaths(layerImplHeaderIncludeDir);
        end

        function GpuEnabled=isGpuCoderEnabled(ctx)
            enableGpuCoderSim=ctx.getConfigProp('GPUAcceleration');
            enableGpuCoderCodegen=ctx.getConfigProp('GenerateGPUCode');
            GpuEnabled=strcmpi(enableGpuCoderSim,'on')||strcmpi(enableGpuCoderCodegen,'CUDA');
        end

        function updateBuildInfoForUserLibs(buildInfo,ctx)

            [~,linkLibExt,~,~]=ctx.getStdLibInfo();


            if isunix
                cudnnLibDir=fullfile(getenv('NVIDIA_CUDNN'),'lib64');
                buildInfo.addSysLibs('cudnn',cudnnLibDir);
                buildInfo.addSysLibs('cublas');
                linkFlags=strcat('-Xlinker -rpath,',cudnnLibDir);
                buildInfo.addLinkFlags(linkFlags);
            elseif ispc
                cudnnLibDir=fullfile(getenv('NVIDIA_CUDNN'),'lib','x64');
                libPriority='';
                libPreCompiled=true;
                libLinkOnly=true;
                libName=strcat('cudnn',linkLibExt);
                buildInfo.addLinkObjects(libName,cudnnLibDir,...
                libPriority,libPreCompiled,libLinkOnly);

            end


            cudnnIncludeDir=fullfile(getenv('NVIDIA_CUDNN'),'include');
            buildInfo.addIncludePaths(cudnnIncludeDir);


        end

        function updateBuildInfoForCrossCompileWorkflow(buildInfo,toolchainName)

            if contains(toolchainName,'NVIDIA CUDA for Jetson Tegra K1 | gmake (64-bit Linux)')
                cudnnLibDir=fullfile(getenv('NVIDIA_CUDNN'),'lib');
            else

                cudnnLibDir=fullfile(getenv('NVIDIA_CUDNN'),'lib64');
            end

            buildInfo.addLinkFlags(['-L',cudnnLibDir]);
            buildInfo.addLinkFlags('-lcudnn');


            cudnnIncludeDir=fullfile(getenv('NVIDIA_CUDNN'),'include');
            buildInfo.addIncludePaths(cudnnIncludeDir);

        end

        function updateBuildInfoForEmbeddedTarget(buildInfo)
            buildInfo.addLinkFlags('-lcudnn -lcublas');

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


        function mexOrStandaloneTarget=isMexOrStandaloneTarget(ctx)
            mexOrStandaloneTarget=ctx.isCodeGenTarget('mex')||~coder.gpu.internal.isEmbeddedTarget(ctx);
        end









        function updateBuildInfo(buildInfo,ctx)

            isHSPTarget=coder.gpu.internal.isEmbeddedTarget(ctx);

            if dltargets.cudnn.cudnnApi.inSimulinkContext(ctx)

                if dltargets.cudnn.cudnnApi.inSimulinkSimulationMode(ctx)


                    assert(~isHSPTarget);
                    dltargets.cudnn.cudnnApi.addShippingLibDeps(buildInfo,ctx);

                    dltargets.cudnn.cudnnApi.addPrecompiledTargetLibraryDeps(buildInfo,ctx);

                elseif dltargets.cudnn.cudnnApi.inSimulinkCodegenMode(ctx)&&~isHSPTarget


                    dltargets.cudnn.cudnnApi.updateBuildInfoForUserLibs(buildInfo,ctx);

                else


                    assert(dltargets.cudnn.cudnnApi.inSimulinkCodegenMode(ctx)&&isHSPTarget);
                    dltargets.cudnn.cudnnApi.updateBuildInfoForEmbeddedTarget(buildInfo);
                end

            else


                config=ctx.getConfigProp('GpuConfig');
                assert(isa(config,'coder.GpuCodeConfig'));
                toolchainName=ctx.getConfigProp('Toolchain');

                if config.UseShippingLibs


                    assert(ctx.isCodeGenTarget('mex'),'UseShippingLibs is only supported for MEX target');
                    dltargets.cudnn.cudnnApi.addShippingLibDeps(buildInfo,ctx);



                elseif dltargets.cudnn.cudnnApi.isMexOrStandaloneTarget(ctx)

                    dltargets.cudnn.cudnnApi.updateBuildInfoForUserLibs(buildInfo,ctx);


                elseif contains(toolchainName,'NVIDIA CUDA for Jetson Tegra K1 | gmake (64-bit Linux)')...
                    ||~isempty(regexp(toolchainName,'NVIDIA CUDA for Jetson Tegra X[12]+ | gmake (64-bit Linux)','ONCE'))

                    dltargets.cudnn.cudnnApi.updateBuildInfoForCrossCompileWorkflow(buildInfo,toolchainName);


                elseif contains(toolchainName,'NVCC for NVIDIA Embedded Processors')


                    assert(isHSPTarget);
                    dltargets.cudnn.cudnnApi.updateBuildInfoForEmbeddedTarget(buildInfo);

                end

            end

            deepLearningConfig=coder.internal.getDeepLearningConfig(ctx);

            if(dlcoderfeature('cuDNNFp16')&&~isempty(deepLearningConfig)&&strcmpi(deepLearningConfig.DataType,'FP16'))
                buildInfo.addDefines('FP16_ENABLED=1');
            end


            if ctx.isCodeGenTarget('mex')
                mexCompilerCppConfig=mex.getCompilerConfigurations('c++');

                if~isempty(mexCompilerCppConfig)
                    mexToolchainName=mexCompilerCppConfig.Name;



                    if ispc||ismac
                        mexToolchainName=mexCompilerCppConfig.Manufacturer;
                    end



                    if deepLearningConfig.Instrumentation
                        sysLib='mwdnn_instrumentation';
                        sysLibPath=dltargets.internal.utils.getMLSysPath(mexToolchainName);
                        buildInfo.addSysLibs(sysLib,sysLibPath);
                    end

                    dltargets.cudnn.cudnnApi.addPrecompiledTargetLibraryDeps(buildInfo,ctx);
                end
            end
        end

        function register()
            coder.inline('always');
            coder.allowpcode('plain');
        end
    end

end

