classdef Convolution2DLayer<nnet.layer.Layer


















%#codegen


    properties(SetAccess=private)
Stride
PaddingSize
Dilation
NumFilters
NumChannels
FilterSize
Algorithm
    end

    properties
Weights
Bias
    end

    methods
        function layer=Convolution2DLayer(name,weights,bias,stride,paddingSize,dilation,...
            numFilters,filterSize,inputSize,buildContext)
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
        end

        function Z=predict(layer,X)

            coder.allowpcode('plain');


            convolutionFunction=coder.internal.layer.convUtils.convolutionFunctionHandleSelector(layer.Algorithm);


            Z=coder.internal.layer.convUtils.computeConvolution(layer,X,convolutionFunction);

        end
    end

    methods(Static,Hidden)
        function n=matlabCodegenNontunableProperties(~)
            n={'Stride','PaddingSize','Dilation','NumFilters','NumChannels','FilterSize',...
            'Algorithm'};
        end
    end
end
