classdef ValidateCrossCompileBase<handle




    properties
        codeConfigObj;
        armComputeLibInfo;
    end

    methods(Abstract)
        validateTargetPlatform();
        validateArmComputeLibEnvVariable();
        validateArmComputeLibArchitecture();
    end

    methods

        function validate(targetObj)
            targetObj.validateTargetPlatform();
            targetObj.validateArmComputeLibEnvVariable();
            targetObj.validateArmComputeLibVersion();
            targetObj.validateArmComputeLibArchitecture();
            targetObj.validateToolChainBinaries();
        end

        function validateArmComputeLibVersion(obj)


            if~contains(obj.armComputeLibInfo,obj.codeConfigObj.DeepLearningConfig.ArmComputeVersion)
                [isSupportedACLVersionBuilt,ACLVersion]=checkACLVersion(obj);
                if~isSupportedACLVersionBuilt


                    error(message('gpucoder:cnnconfig:ARMComputeVersionMismatch',obj.codeConfigObj.DeepLearningConfig.ArmComputeVersion,ACLVersion));
                else



                    disp(['### Found Arm Compute Library built with "',ACLVersion,'" version. Forcing ARMComputeVersion to ',ACLVersion,'.']);
                    obj.codeConfigObj.DeepLearningConfig.ArmComputeVersion=ACLVersion;
                end
            end
        end

        function[isSupportedACLVersionBuilt,ACLVersion]=checkACLVersion(obj)
            OutputVersion=strsplit(obj.armComputeLibInfo,' Build');
            OutputVersion=strsplit(OutputVersion{1},'=v');
            ACLVersion=OutputVersion{2};
            if any(strcmp(ACLVersion,obj.codeConfigObj.DeepLearningConfig.getARMComputeSupportedVersions()))
                isSupportedACLVersionBuilt=true;
            else
                isSupportedACLVersionBuilt=false;
            end
        end

        function validateToolChainBinaries(~)
        end

    end

end
