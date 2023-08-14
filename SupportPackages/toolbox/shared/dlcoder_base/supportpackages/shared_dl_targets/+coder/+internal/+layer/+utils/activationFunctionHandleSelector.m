function activationFunctionHandle=activationFunctionHandleSelector(activationFunctionType,activationParameters,...
    dataType)

















%#codegen


    coder.allowpcode('plain')

    coder.internal.assert(strcmp(dataType,'single'),'dlcoder_spkg:cnncodegen:DLCoderInternalError');

    zeroCast=zeros(1,1,dataType);
    oneCast=ones(1,1,dataType);

    switch coder.const(activationFunctionType)
    case 'ReLU'
        activationFunctionHandle=@(x)max(zeroCast,cast(x,dataType));
    case 'Tanh'
        activationFunctionHandle=@(x)tanh(cast(x,dataType));
    case 'Sigmoid'
        activationFunctionHandle=@(x)oneCast/(oneCast+exp(-cast(x,dataType)));
    case 'ELU'
        alphaCast=cast(activationParameters.Alpha,dataType);
        activationFunctionHandle=@(x)max(zeroCast,cast(x,dataType))+...
        alphaCast*(exp(min(zeroCast,cast(x,dataType)))-1);
    case 'ClippedReLU'
        ceilingCast=cast(activationParameters.Ceiling,dataType);
        activationFunctionHandle=@(x)min(max(zeroCast,cast(x,dataType)),ceilingCast);
    case 'LeakyReLU'
        scaleCast=cast(activationParameters.Scale,dataType);
        activationFunctionHandle=@(x)max(zeroCast,cast(x,dataType),'includenan')+...
        scaleCast.*min(zeroCast,cast(x,dataType));
    end

end

