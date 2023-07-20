classdef Convolution2DBatchNormActivation<nnet.layer.Layer&coder.internal.layer.FusedLayer























%#codegen

    properties(SetAccess=private)





LayerFused
LayerUnfused


Algorithm


ActivationParams



ActivationFunctionType
    end

    methods
        function layer=Convolution2DBatchNormActivation(name,weightsUnfused,biasUnfused,...
            weightsFused,biasFused,stride,paddingSize,dilation,numFilters,filterSize,...
            inputSize,buildContext,activationParams,activationFunctionType)

            layer.Name=name;


            layer.ActivationParams=activationParams;
            layer.ActivationFunctionType=activationFunctionType;




            [layer.LayerFused,layer.LayerUnfused]=...
            coder.internal.layer.convUtils.populateConv2DBatchNormParams(name,...
            weightsUnfused,biasUnfused,weightsFused,biasFused,stride,paddingSize,...
            dilation,numFilters,filterSize,inputSize,buildContext);



            layer.Algorithm=layer.LayerFused.Algorithm;
        end

        function Z=predict(layer,X)

            coder.allowpcode('plain');


            convolutionFunction=coder.internal.layer.convUtils.convolutionFunctionHandleSelector(layer.Algorithm);




            if layer.ActivationLayerOffset==1



                Z=coder.internal.layer.convUtils.computeConvolution(layer.LayerUnfused,X,convolutionFunction);
            elseif layer.ActivationLayerOffset==2




                Z=coder.internal.layer.convUtils.computeConvolution(layer.LayerFused,X,convolutionFunction);
            else




                activationFunction=coder.internal.layer.utils.activationFunctionHandleSelector(layer.ActivationFunctionType,...
                layer.ActivationParams,class(X));



                Z=coder.internal.layer.convUtils.computeConvolution(layer.LayerFused,X,convolutionFunction,...
                'ActivationFunction',activationFunction,...
                'ActivationFunctionType',layer.ActivationFunctionType,...
                'ActivationParams',layer.ActivationParams);
            end
        end
    end

    methods(Static,Hidden)
        function n=matlabCodegenNontunableProperties(~)
            n={'Algorithm','ActivationFunctionType'};
        end
    end
end
