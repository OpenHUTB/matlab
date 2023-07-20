classdef armmaliApi<coder.ExternalDependency&coder.internal.JITSupportedExternalDependency




%#codegen
    methods(Static)
        function bName=getDescriptiveName(~)
            bName='armmaliApi';
        end

        function tf=isSupportedContext(ctx)
            config=ctx.getConfigProp('DeepLearningConfig');
            if isa(config,'coder.ARMMALIConfig')
                tf=true;
                return;
            end
            tf=false;
        end

        function updateBuildInfo(buildInfo,ctx)
            config=ctx.getConfigProp('DeepLearningConfig');
            assert(isa(config,'coder.ARMMALIConfig'));


            buildInfo.addSysLibs('arm_compute_core','$(ARM_COMPUTELIB)/lib');
            buildInfo.addSysLibs('arm_compute','$(ARM_COMPUTELIB)/lib');
            buildInfo.addSysLibs('OpenCL','$(ARM_COMPUTELIB)/lib');

            buildInfo.addKeyValuePair('MakeVar','override START_DIR','.');


            armVersion=strrep(config.ArmComputeVersion,'.','_');
            defineFlag=['USE_',armVersion,'_LIBRARY'];
            buildInfo.addDefines(defineFlag);


            armcomputeIncludeDir='$(ARM_COMPUTELIB)';
            buildInfo.addIncludePaths(armcomputeIncludeDir);
            armcomputeIncludeDir=[armcomputeIncludeDir,'/include'];
            buildInfo.addIncludePaths(armcomputeIncludeDir);


            buildInfo.addCompileFlags(' -std=c++11');

        end

        function register()
            coder.inline('always');
            coder.allowpcode('plain');
        end

    end

end
