classdef ActivationLayer<nnet.layer.Layer&coder.internal.layer.NumericDataLayer




%#codegen


    properties
ActivationFunctionType
ActivationParams
    end

    methods
        function layer=ActivationLayer(name,activationFunctionType,activationParams)
            layer.Name=name;
            layer.ActivationFunctionType=activationFunctionType;
            layer.ActivationParams=activationParams;
        end

        function X=predict(layer,X)
            coder.allowpcode('plain');
            coder.inline('always');

            if coder.const(isa(X,'dlarray'))

                dataType=class(extractdata(X(1)));
            else
                dataType=class(X);
            end

            activationFunction=coder.internal.layer.utils.activationFunctionHandleSelector(...
            layer.ActivationFunctionType,layer.ActivationParams,dataType);

            X=coder.internal.layer.computeElementwiseOperation(activationFunction,X);
        end
    end

end
