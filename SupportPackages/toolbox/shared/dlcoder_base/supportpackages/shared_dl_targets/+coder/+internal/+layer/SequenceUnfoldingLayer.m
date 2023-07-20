classdef SequenceUnfoldingLayer<nnet.layer.Layer&coder.internal.layer.NumericDataLayer



































%#codegen
    properties
InputFormat
OutputFormat
MiniBatchSize
    end

    methods
        function this=SequenceUnfoldingLayer(name,inputFormat,outputFormat,miniBatchSize)
            this.Name=name;
            this.InputFormat=inputFormat;
            this.OutputFormat=outputFormat;
            this.InputNames=["in","miniBatchSize"];
            this.OutputNames="out";
            this.MiniBatchSize=miniBatchSize;
        end

        function Z=predict(layer,X,~)
            coder.allowpcode('plain');

            inputFormat=coder.const(layer.InputFormat{1});
            outputFormat=coder.const(layer.OutputFormat{1});
            miniBatchSize=coder.const(layer.MiniBatchSize);

            Z=coder.internal.layer.foldingUnfoldingUtils.unfoldingOperation(X,inputFormat,...
            outputFormat,miniBatchSize);
        end
    end

    methods(Static,Hidden)
        function n=matlabCodegenNontunableProperties(~)
            n={'InputFormat','OutputFormat','MiniBatchSize'};
        end
    end
end
