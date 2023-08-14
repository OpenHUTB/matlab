classdef FullyConnectedActivation<nnet.layer.Layer&coder.internal.layer.FusedLayer




%#codegen


    properties(SetAccess=private)
InputSize
OutputSize
ActivationParams
ActivationFunctionType
    end

    properties
Weights
Bias
    end

    methods
        function layer=FullyConnectedActivation(name,weights,bias,inputSize,outputSize,activationParams,activationFunctionType)
            layer.Name=name;
            layer.Weights=weights;
            layer.Bias=bias;
            layer.InputSize=inputSize;
            layer.OutputSize=outputSize;
            layer.ActivationParams=activationParams;
            layer.ActivationFunctionType=activationFunctionType;
            layer.Type='FullyConnectedActivation';
            layer.Description=['Fully connected layer followed by ',char(activationFunctionType)...
            ,' activation.'];
        end

        function Z=predict(layer,X)
            coder.allowpcode('plain');

            if layer.ActivationLayerOffset~=1




                activationFunction=coder.internal.layer.utils.activationFunctionHandleSelector(layer.ActivationFunctionType,...
                layer.ActivationParams,class(X));


                layerOutput=coder.internal.layer.fullyConnectedForward(layer,X,'ActivationFunction',activationFunction);

            else


                layerOutput=coder.internal.layer.fullyConnectedForward(layer,X);
            end

            if(coder.const(numel(layer.InputSize))==1)



                Z=reshape(layerOutput,size(layer.Weights,1),size(X,2),size(X,3));
            else


                Z=reshape(layerOutput,1,1,size(layer.Weights,1),size(X,4));
            end

        end

    end

    methods(Static,Hidden)
        function n=matlabCodegenNontunableProperties(~)
            n={'InputSize','OutputSize','ActivationParams','ActivationFunctionType'};
        end
    end
end
