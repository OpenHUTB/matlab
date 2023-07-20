classdef Convolution2DActivation<coder.internal.layer.quantized.Layer&coder.internal.layer.FusedLayer






















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
            dilation,numFilters,filterSize,buildContext,activationParams,...
            activationFunctionType,inDataSize,inDataType,outDataType)
            layer.Name=name;
            layer.Weights=weights;
            layer.Bias=bias;
            layer.Stride=stride;
            layer.PaddingSize=paddingSize;
            layer.Dilation=dilation;
            layer.NumFilters=numFilters;
            layer.NumChannels=size(weights,3);
            layer.FilterSize=filterSize;




            [layer.Algorithm,layer.Weights,layer.Bias]=...
            coder.internal.layer.convUtils.convolutionDispatcherSelector(layer,inDataSize,buildContext);

            layer.ActivationParams=activationParams;
            layer.ActivationFunctionType=activationFunctionType;
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

            if layer.ActivationLayerOffset~=1




                activationFunction=coder.internal.layer.utils.activationFunctionHandleSelector(...
                layer.ActivationFunctionType,layer.ActivationParams,'single');




                Z=convolutionFunction(layer,X,'ActivationFunction',activationFunction,...
                'PrototypeData',layer.OutDataType);

            else




                Z=convolutionFunction(layer,X,'PrototypeData',layer.OutDataType);
            end

        end

    end

    methods(Static,Hidden)
        function n=matlabCodegenNontunableProperties(~)
            n={'Stride','PaddingSize','Dilation','NumFilters','NumChannels','FilterSize',...
            'Algorithm','ActivationParams','ActivationFunctionType','InDataType','OutDataType'};
        end
    end

end
