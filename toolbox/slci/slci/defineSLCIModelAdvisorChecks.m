function defineSLCIModelAdvisorChecks



    if~ismac()

        SLCIModelConfigurationSettings;

        ModelWideConstraintChecks;

        SLCIBlocks;

        SLCIStateflow;

        SLCIMatlabObjects;

        SLCIMixChecks;
    end
end
