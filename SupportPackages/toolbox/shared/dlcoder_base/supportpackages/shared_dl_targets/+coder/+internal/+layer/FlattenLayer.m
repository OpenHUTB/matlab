classdef FlattenLayer<nnet.layer.Layer&coder.internal.layer.NumericDataLayer

































%#codegen
    properties
InputFormat
OutputFormat
    end

    methods
        function this=FlattenLayer(name,inputFormat,outputFormat)
            this.Name=name;
            this.InputFormat=inputFormat;
            this.OutputFormat=outputFormat;
        end

        function Z=predict(layer,X)
            coder.allowpcode('plain');

            inputFormat=layer.InputFormat{1};
            numSpatialDims=coder.const(coder.internal.layer.utils.numSpatialDims(inputFormat));
            if coder.const(numSpatialDims)>0

                Z=coder.internal.layer.flattenUtils.flatteningOperation(X,inputFormat,numSpatialDims);
            else

                Z=X;
            end
        end
    end

    methods(Static,Hidden)
        function n=matlabCodegenNontunableProperties(~)
            n={'InputFormat','OutputFormat'};
        end
    end
end