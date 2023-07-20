classdef clippedRelu<nnet.layer.Layer&coder.internal.layer.NumericDataLayer











%#codegen


    methods
        function layer=clippedRelu(name,ceiling)
            layer.Name=name;
            layer.ceiling=ceiling;
        end

        function Z1=predict(~,X1)
            coder.allowpcode('plain');
            coder.inline('always');

            Z1=X1;

            Z1(~(X1>0))=0;
            Z1(X1>ceiling)=ceiling;
        end

    end
end
