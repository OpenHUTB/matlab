classdef helperResizeLayer<nnet.layer.Layer


    properties

        LearnableParameters=nnet.internal.cnn.layer.learnable.PredictionLearnableParameter.empty();


        outsize;
    end
    properties(Constant)

        DefaultName='resize'
    end
    methods
        function layer=helperResizeLayer(name,size)


            layer.Name=name;
            layer.outsize=size;


            layer.Description='resizeLayer';
        end
        function Z=predict(layer,X)


            Z=ones(layer.outsize).*X;
        end
        function dLdX=backward(layer,X,Z,dLdZ,memory)
















            dLdX=sum(sum(dLdZ));
        end
    end
end