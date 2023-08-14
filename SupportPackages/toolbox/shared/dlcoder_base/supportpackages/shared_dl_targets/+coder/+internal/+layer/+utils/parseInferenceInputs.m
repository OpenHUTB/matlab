function[params,hasActivation]=parseInferenceInputs(varargin)












%#codegen


    coder.allowpcode('plain')

    defaultParams.ActivationFunction=@coder.internal.layer.utils.defaultActivation;
    defaultParams.ActivationFunctionType='';
    defaultParams.ActivationParams=struct;
    defaultParams.PrototypeData=varargin{end};

    [params,userSuppliedParams]=coder.internal.nvparse(defaultParams,varargin{1:end-1});

    if coder.const(userSuppliedParams.ActivationFunction)
        coder.internal.assert(userSuppliedParams.ActivationFunctionType,...
        'dlcoder_spkg:cnncodegen:DLCoderInternalError');
        coder.internal.assert(userSuppliedParams.ActivationParams,...
        'dlcoder_spkg:cnncodegen:DLCoderInternalError');
        hasActivation=true;
    else
        coder.internal.assert(~userSuppliedParams.ActivationFunctionType,...
        'dlcoder_spkg:cnncodegen:DLCoderInternalError');
        coder.internal.assert(~userSuppliedParams.ActivationParams,...
        'dlcoder_spkg:cnncodegen:DLCoderInternalError');
        hasActivation=false;
    end

end

