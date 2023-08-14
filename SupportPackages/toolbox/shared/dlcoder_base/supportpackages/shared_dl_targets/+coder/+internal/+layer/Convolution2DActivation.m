classdef Convolution2DActivation<nnet.layer.Layer&coder.internal.layer.FusedLayer





















%#codegen


    properties(SetAccess=private)
Stride
PaddingSize
Dilation
NumFilters
NumChannels
FilterSize
Algorithm
ActivationParams
ActivationFunctionType
    end

    properties
Weights
Bias
    end

    methods
        function layer=Convolution2DActivation(name,weights,bias,stride,paddingSize,...
            dilation,numFilters,filterSize,inputSize,buildContext,activationParams,...
            activationFunctionType)
            layer.Name=name;
            layer.Weights=weights;
            layer.Bias=bias;
            layer.Stride=stride;
            layer.PaddingSize=paddingSize;
            layer.Dilation=dilation;
            layer.NumChannels=size(weights,3);
            layer.NumFilters=numFilters;
            layer.FilterSize=filterSize;



            [layer.Algorithm,layer.Weights,layer.Bias]=...
            coder.internal.layer.convUtils.convolutionDispatcherSelector(layer,inputSize,buildContext);

            layer.ActivationParams=activationParams;
            layer.ActivationFunctionType=activationFunctionType;
        end

        function Z=predict(layer,X)

            coder.allowpcode('plain');



            convolutionFunction=coder.internal.layer.convUtils.convolutionFunctionHandleSelector(layer.Algorithm);




            if layer.ActivationLayerOffset~=1




                activationFunction=coder.internal.layer.utils.activationFunctionHandleSelector(layer.ActivationFunctionType,layer.ActivationParams,...
                class(X));



                Z=coder.internal.layer.convUtils.computeConvolution(layer,X,convolutionFunction,...
                'ActivationFunction',activationFunction,...
                'ActivationFunctionType',layer.ActivationFunctionType,...
                'ActivationParams',layer.ActivationParams);

            else




                Z=coder.internal.layer.convUtils.computeConvolution(layer,X,convolutionFunction);
            end
        end
    end

    methods(Static,Hidden)
        function n=matlabCodegenNontunableProperties(~)
            n={'Stride','PaddingSize','Dilation','NumFilters','NumChannels','FilterSize',...
            'Algorithm','ActivationParams','ActivationFunctionType'};
        end
    end
end
