%#codegen


function validateStatefulCall(isRNN,functionName)





    coder.allowpcode('plain');
    coder.gpu.internal.kernelfunImpl(false);
    coder.internal.assert(isRNN,...
    'dlcoder_spkg:cnncodegen:FunctionUnsupportedForNonRecurrentNetworks',...
    functionName);




    supportedTargets={'cudnn','tensorrt','arm-compute','mkldnn','none'};

    targetLib=coder.internal.coderNetworkUtils.getTargetLib;
    coder.internal.assert(coder.const(any(strcmpi(targetLib,supportedTargets))),...
    'dlcoder_spkg:cnncodegen:FunctionUnsupportedForTargetLib',...
    functionName,...
    coder.const(targetLib));
end
