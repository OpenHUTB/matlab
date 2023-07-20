classdef PassThroughLayer<nnet.layer.Layer&coder.internal.layer.NumericDataLayer




%#codegen


    methods
        function layer=PassThroughLayer(name)
            layer.Name=name;
        end

        function Z1=predict(~,X1)
            coder.allowpcode('plain');
            coder.inline('always');

            Z1=X1;
        end

    end
end
