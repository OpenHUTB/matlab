function X=computeElementwiseOperation(activationFunction,X)











%#codegen
    coder.allowpcode('plain');
    coder.inline('always');


    if coder.const(coder.internal.coderNetworkUtils.isSfunOrRtwCodeConfig())

        X=coder.internal.layer.elementwiseOperation(activationFunction,X,X(1));
    else

        X=coder.internal.layer.elementwiseOperationInPlace(activationFunction,X);
    end
end

