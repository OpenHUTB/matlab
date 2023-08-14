
function isSupported=isActivationSupportedForCgirFusion(activationFcnType)



    supportedActivations={'RELU','LEAKYRELU'};
    isSupported=ismember(upper(activationFcnType),supportedActivations);
end