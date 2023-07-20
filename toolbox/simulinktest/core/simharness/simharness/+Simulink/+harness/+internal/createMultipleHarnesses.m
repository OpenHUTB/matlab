function[harnessInfo,status,warnMessages]=createMultipleHarnesses(harnessOwners,topModel,varargin)








































































    createForLoad=false;
    checkoutSLTLicence=true;

    try
        [harnessInfo,status,warnMessages]=Simulink.harness.internal...
        .createHarnessBatch(harnessOwners,topModel,createForLoad,...
        checkoutSLTLicence,varargin{:});
    catch me
        throwAsCaller(me);
    end
end
