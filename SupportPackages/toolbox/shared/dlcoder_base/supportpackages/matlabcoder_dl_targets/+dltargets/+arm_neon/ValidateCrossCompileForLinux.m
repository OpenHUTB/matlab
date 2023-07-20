classdef ValidateCrossCompileForLinux<dltargets.arm_neon.ValidateCrossCompileBase




    methods
        function obj=ValidateCrossCompileForLinux(cfgObj)
            obj.codeConfigObj=cfgObj;
        end
    end

    methods

        function validateTargetPlatform(targetObj)
            if~isunix


                error(message('gpucoder:cnnconfig:UnsupportedToolchainSpecified',targetObj.codeConfigObj.Toolchain,computer('arch')));
            end
        end

        function validateArmComputeLibEnvVariable(obj)






            if isempty(getenv('ARM_COMPUTELIB'))||~isfolder(getenv('ARM_COMPUTELIB'))

                error(message('gpucoder:cnnconfig:UnspecifiedEnvironmentVariable','ARM_COMPUTELIB','Cross Compiled ComputeLibrary'));
            end



            CrossCompiledLibs={'libarm_compute.so','libarm_compute_core.so'};
            CrossCompiledLibsString='libarm_compute.so, libarm_compute_core.so';

            if~isfolder(fullfile(getenv('ARM_COMPUTELIB'),'lib'))||~all(isfile(fullfile(getenv('ARM_COMPUTELIB'),'lib',CrossCompiledLibs)))

                error(message('gpucoder:cnnconfig:MissingARMComputeLibraries',CrossCompiledLibsString,fullfile(getenv('ARM_COMPUTELIB'),'lib')));
            end

            [~,obj.armComputeLibInfo]=system(['strings ',fullfile(getenv('ARM_COMPUTELIB'),'lib','libarm_compute.so'),' | grep arm_compute_version']);
        end

        function validateArmComputeLibArchitecture(obj)

            if~isempty(obj.codeConfigObj.DeepLearningConfig.ArmArchitecture)
                if(strcmp(obj.codeConfigObj.Toolchain,'Linaro AArch64 Linux v6.3.1')&&strcmpi(obj.codeConfigObj.DeepLearningConfig.ArmArchitecture,'armv7'))


                    warning(message('gpucoder:cnnconfig:TargetArchitectureMismatch',obj.codeConfigObj.DeepLearningConfig.ArmArchitecture,obj.codeConfigObj.Toolchain,'armv8'));
                    obj.codeConfigObj.DeepLearningConfig.ArmArchitecture='armv8';
                end
                if(strcmp(obj.codeConfigObj.Toolchain,'Linaro AArch32 Linux v6.3.1')&&strcmpi(obj.codeConfigObj.DeepLearningConfig.ArmArchitecture,'armv8'))


                    warning(message('gpucoder:cnnconfig:TargetArchitectureMismatch',obj.codeConfigObj.DeepLearningConfig.ArmArchitecture,obj.codeConfigObj.Toolchain,'armv7'));
                    obj.codeConfigObj.DeepLearningConfig.ArmArchitecture='armv7';
                end
            else
                if strcmp(obj.codeConfigObj.Toolchain,'Linaro AArch64 Linux v6.3.1')
                    obj.codeConfigObj.DeepLearningConfig.ArmArchitecture='armv8';
                else
                    obj.codeConfigObj.DeepLearningConfig.ArmArchitecture='armv7';
                end
            end


            if strcmp(obj.codeConfigObj.Toolchain,'Linaro AArch32 Linux v6.3.1')
                if~contains(obj.armComputeLibInfo,'armv7a')


                    error(message('gpucoder:cnnconfig:ARMComputeArchitectureMismatch','armv7a',obj.codeConfigObj.Toolchain));
                end
            else
                if~contains(obj.armComputeLibInfo,'arm64-v8a')


                    error(message('gpucoder:cnnconfig:ARMComputeArchitectureMismatch','arm64-v8a',obj.codeConfigObj.Toolchain));
                end
            end
        end

        function validateToolChainBinaries(obj)

            if strcmp(obj.codeConfigObj.Toolchain,'Linaro AArch32 Linux v6.3.1')

                if isempty(getenv('LINARO_TOOLCHAIN_AARCH32'))
                    thirdpartyTool='linarogcctoolchain_aarch32.instrset';
                    rootDir=matlab.internal.get3pInstallLocation(thirdpartyTool);
                    if isempty(rootDir)



                        error(message('gpucoder:cnnconfig:UnspecifiedEnvironmentVariable','LINARO_TOOLCHAIN_AARCH32','Linaro AARCH32 bit toolchain binaries'));
                    end
                else
                    matlabshared.toolchain.gcc_linaro.internal.setLinaroAArch32ToolchainPath(getenv('LINARO_TOOLCHAIN_AARCH32'));
                end
            else
                if isempty(getenv('LINARO_TOOLCHAIN_AARCH64'))
                    thirdpartyTool='linarogcctoolchain_6_3.instrset';
                    rootDir=matlab.internal.get3pInstallLocation(thirdpartyTool);
                    if isempty(rootDir)

                        rootDir=matlab.internal.get3pInstallLocation('linarogcctoolchain_6_3_soc.instrset');
                        if isempty(rootDir)


                            error(message('gpucoder:cnnconfig:UnspecifiedEnvironmentVariable','LINARO_TOOLCHAIN_AARCH64','Linaro AARCH64 bit toolchain binaries'));
                        end
                    end
                else
                    matlabshared.toolchain.gcc_linaro.internal.setLinaroAArch64ToolchainPath(getenv('LINARO_TOOLCHAIN_AARCH64'));
                end
            end
        end

    end

end
