classdef ConcatenationLayer<nnet.layer.Layer




%#codegen


    properties(SetAccess=private)
Dim
    end

    methods
        function layer=ConcatenationLayer(name,numInputs,dim,inputNames)
            layer.Name=name;
            layer.NumInputs=numInputs;
            layer.Dim=dim;
            layer.InputNames=inputNames;
            layer.OutputNames="out";

        end

        function Z=predict(layer,varargin)
            coder.allowpcode('plain');
            coder.inline('always');

            Z=cat(layer.Dim,varargin{:});
        end

    end
end