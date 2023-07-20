function Z=fullyConnectedForward(layer,X,varargin)






















%#codegen


    coder.allowpcode('plain');


    narginchk(2,4);


    weights=layer.Weights;
    bias=layer.Bias;


    args=coder.internal.layer.utils.parseInferenceInputs(varargin{:},X);
    activationFunction=args.ActivationFunction;


    Z=coder.internal.layer.optimized.matMulAdd(weights,reshape(X,size(weights,2),[]),bias,activationFunction);

end
