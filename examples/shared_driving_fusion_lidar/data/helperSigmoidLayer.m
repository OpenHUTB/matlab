classdef helperSigmoidLayer<nnet.layer.Layer


    methods
        function layer=helperSigmoidLayer(name)

            layer.Name=name;

            layer.Description='sigmoidLayer';
        end
        function Z=predict(~,X)


            Z=exp(X)./(exp(X)+1);
        end
        function dLdX=backward(layer,X,Z,dLdZ,memory)














            dLdX=Z.*(1-Z).*dLdZ;
        end
    end
end