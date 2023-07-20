classdef armcomputeApi<coder.ExternalDependency&coder.internal.JITSupportedExternalDependency






%#codegen
    methods(Static)
        function bName=getDescriptiveName(~)
            bName='armcomputeApi';
        end

        function tf=isSupportedContext(ctx)
            config=ctx.getConfigProp('DeepLearningConfig');
            if isa(config,'coder.ARMNEONConfig')
                tf=true;
                return;
            end
            tf=false;
        end


        function addDlDataPathIfNeeded(buildInfo,ctx)
            isSimulink=isempty(ctx.getConfigProp('DeepLearningConfig'));
            if~isSimulink&&strcmpi(ctx.getConfigProp('VerificationMode'),'PIL')

                dltargets.arm_neon.armcomputeApi.addDlDataPathForPIL(buildInfo);
            end
        end


        function addDlDataPathForPIL(buildInfo)
            buildInfo.addDefines('MW_DL_DATA_PATH=$(START_DIR)');
        end


        function updateBuildInfo(buildInfo,ctx)
            dlConfig=coder.internal.getDeepLearningConfig(ctx);

            if any(strcmp(ctx.getToolchainInfo.Name,{'GNU Tools for ARM_COMPUTE ','GNU gcc/g++ | gmake (64-bit Linux)'}))
                buildInfo.addSysLibs('arm_compute_core','$(ARM_COMPUTELIB)/lib');
                buildInfo.addSysLibs('arm_compute','$(ARM_COMPUTELIB)/lib');
            elseif any(strcmp(ctx.getToolchainInfo.Name,...
                {'GNU GCC for NVIDIA Embedded Processors','NVCC for NVIDIA Embedded Processors'}))||...
                (isa(ctx.ConfigData,'Simulink.ConfigSet')&&...
                any(strcmp(ctx.ConfigData.get_param('HardwareBoard'),{'NVIDIA Jetson','NVIDIA Drive'})))
                LinkFlags='-larm_compute -larm_compute_core -L$(ARM_COMPUTELIB)/lib';
                buildInfo.addLinkFlags(LinkFlags,'CustomLibFlags');
            else
                LinkFlags='-L"$(ARM_COMPUTELIB)/lib" -rdynamic -larm_compute -larm_compute_core -Wl,-rpath,"$(ARM_COMPUTELIB)/lib":-L"$(ARM_COMPUTELIB)/lib"';
                buildInfo.addLinkFlags(LinkFlags);
            end
            if any(strcmp(ctx.getToolchainInfo.Name,{'Linaro AArch32 Linux v6.3.1','Linaro AArch64 Linux v6.3.1'}))
                buildInfo.addKeyValuePair('MakeVar','ARM_COMPUTELIB',getenv('ARM_COMPUTELIB'));
            end

            isSimulink=isempty(ctx.getConfigProp('DeepLearningConfig'));
            if isSimulink
                if strcmp(ctx.getConfigProp('GenCodeOnly'),'on')
                    buildInfo.addKeyValuePair('MakeVar','override START_DIR','.');
                end
            else
                if ctx.getConfigProp('GenCodeOnly')
                    buildInfo.addKeyValuePair('MakeVar','override START_DIR','.');
                end
            end

            defineFlag=['USE_',strrep(dlConfig.ArmComputeVersion,'.','_'),'_LIBRARY'];
            buildInfo.addDefines(defineFlag);

            armcomputeIncludeDir='$(ARM_COMPUTELIB)';
            buildInfo.addIncludePaths(armcomputeIncludeDir);
            armcomputeIncludeDir=[armcomputeIncludeDir,'/include'];
            buildInfo.addIncludePaths(armcomputeIncludeDir);
            buildInfo.addCompileFlags(' -std=c++11')
            if strcmpi(dlConfig.ArmArchitecture,'armv7')
                buildInfo.addCompileFlags(' -mfpu=neon')
            end


            dltargets.arm_neon.armcomputeApi.addDlDataPathIfNeeded(buildInfo,ctx);


            buildInfo.addCompileFlags(' -fopenmp');
            buildInfo.addLinkFlags(' -fopenmp');
        end

        function register()
            coder.inline('always');
            coder.allowpcode('plain');
        end

    end
end
