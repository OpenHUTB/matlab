classdef AdditionLayer<nnet.layer.Layer




%#codegen


    methods
        function layer=AdditionLayer(name,numInputs,inputNames)
            layer.Name=name;
            layer.NumInputs=numInputs;
            layer.InputNames=inputNames;
            layer.OutputNames="out";
        end

        function Z=predict(~,varargin)
            coder.allowpcode('plain');
            coder.inline('always');

            Z=varargin{1};
            for idxInput=2:numel(varargin)
                Z=Z+varargin{idxInput};
            end
        end
    end

end
