classdef BatchNormalizationLayer<nnet.layer.Layer









%#codegen
    properties
        CombinedBeta;
        CombinedGamma;
InputFormat
    end

    methods
        function layer=BatchNormalizationLayer(name,combinedBeta,combinedGamma,inputFormat)
            layer.Name=name;
            layer.CombinedBeta=combinedBeta;
            layer.CombinedGamma=combinedGamma;
            layer.InputFormat=inputFormat;
        end

        function Z=predict(layer,X)
            coder.allowpcode('plain');
            coder.inline('always');




            noActivationFun=@(x)x;
            if coder.const(contains(layer.InputFormat,'S'))


                Z=coder.internal.layer.batchNormUtils.batchNormOpInPlaceWithSpatialDims(layer,noActivationFun,X);
            else


                Z=coder.internal.layer.batchNormUtils.batchNormOpInPlaceWithoutSpatialDims(layer,noActivationFun,X);
            end
        end
    end

    methods(Static,Hidden)
        function n=matlabCodegenNontunableProperties(~)
            n={'InputFormat'};
        end
    end
end
