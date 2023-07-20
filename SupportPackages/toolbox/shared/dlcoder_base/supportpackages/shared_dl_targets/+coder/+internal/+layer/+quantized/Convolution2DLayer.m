classdef Convolution2DLayer<coder.internal.layer.quantized.Layer


















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
            numFilters,filterSize,buildContext,inputSize,inDataType,outDataType)
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

            layer.InDataType=inDataType;
            layer.OutDataType=outDataType;
        end

        function Z=predict(layer,XInit)

            coder.allowpcode('plain');


            convolutionFunction=coder.internal.layer.convUtils.convolutionFunctionHandleSelector(...
            layer.Algorithm);


            if coder.const(~isa(XInit,'embedded.fi'))

                X=coder.internal.layer.elementwiseOperation(@(x)cast(x,'like',layer.InDataType),XInit,layer.InDataType);
            else
                X=XInit;
            end


            Z=convolutionFunction(layer,X,'PrototypeData',layer.OutDataType);
        end

    end

    methods(Static,Hidden)
        function n=matlabCodegenNontunableProperties(~)
            n={'Stride','PaddingSize','Dilation','NumFilters','NumChannels','FilterSize',...
            'Algorithm','InDataType','OutDataType'};
        end
    end
end
