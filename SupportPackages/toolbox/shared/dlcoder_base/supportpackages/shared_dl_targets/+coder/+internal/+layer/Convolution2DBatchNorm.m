classdef Convolution2DBatchNorm<nnet.layer.Layer&coder.internal.layer.FusedLayer





















%#codegen

    properties(SetAccess=private)





LayerFused
LayerUnfused


Algorithm
    end

    methods
        function layer=Convolution2DBatchNorm(name,weightsUnfused,biasUnfused,weightsFused,biasFused,stride,...
            paddingSize,dilation,numFilters,filterSize,inputSize,buildContext)

            layer.Name=name;




            [layer.LayerFused,layer.LayerUnfused]=coder.internal.layer.convUtils.populateConv2DBatchNormParams(name,...
            weightsUnfused,biasUnfused,weightsFused,biasFused,stride,paddingSize,dilation,numFilters,...
            filterSize,inputSize,buildContext);



            layer.Algorithm=layer.LayerFused.Algorithm;
        end

        function Z=predict(layer,X)

            coder.allowpcode('plain');



            convolutionFunction=coder.internal.layer.convUtils.convolutionFunctionHandleSelector(layer.Algorithm);




            if layer.ActivationLayerOffset~=1




                Z=coder.internal.layer.convUtils.computeConvolution(layer.LayerFused,X,convolutionFunction);
            else



                Z=coder.internal.layer.convUtils.computeConvolution(layer.LayerUnfused,X,convolutionFunction);
            end
        end
    end

    methods(Static,Hidden)
        function n=matlabCodegenNontunableProperties(~)
            n={'Algorithm'};
        end
    end
end
