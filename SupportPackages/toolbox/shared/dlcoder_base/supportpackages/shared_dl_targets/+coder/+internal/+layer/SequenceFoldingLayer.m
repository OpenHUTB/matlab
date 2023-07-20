classdef SequenceFoldingLayer<nnet.layer.Layer&coder.internal.layer.NumericDataLayer



































%#codegen
    properties
InputFormat
OutputFormat
MiniBatchSize
    end

    methods
        function this=SequenceFoldingLayer(name,inputFormat,outputFormat,miniBatchSize)
            this.Name=name;
            this.InputFormat=inputFormat;
            this.OutputFormat=outputFormat;
            this.InputNames="in";
            this.OutputNames=["out","miniBatchSize"];
            this.MiniBatchSize=miniBatchSize;
        end

        function[Z,miniBatchSize]=predict(layer,X)
            coder.allowpcode('plain');


            inputFormat=layer.InputFormat{1};



            miniBatchSize=coder.const([1,layer.MiniBatchSize,1]);

            Z=coder.internal.layer.foldingUnfoldingUtils.foldingOperation(X,inputFormat);
        end
    end

    methods(Static,Hidden)
        function n=matlabCodegenNontunableProperties(~)
            n={'InputFormat','OutputFormat','MiniBatchSize'};
        end
    end

end