










function params=packageActivationParamsForCgirFusion(activationFcnType,paramStruct)



    params={coder.internal.indexInt(0)};
    if~coder.internal.layer.utils.isActivationSupportedForCgirFusion(activationFcnType)
        return
    end

    if strcmpi(activationFcnType,'LEAKYRELU')
        numParams=numel(fieldnames(paramStruct));
        assert(numParams==1,'Expected one parameter for LeakyReLU');
        assert(isfield(paramStruct,'Scale'),'Expected LeakyReLU to have a ''scale'' parameter');
        params={coder.internal.indexInt(numParams),single(paramStruct.Scale)};
    end




end