classdef LayerAnalysis<handle



    methods(Static)

        function isClassificationOutputLayer=isClassificationOutputLayer(layer)



            ilayer=nnet.cnn.layer.Layer.getInternalLayers(layer);

            isClassificationOutputLayer=isa(ilayer{1},'nnet.internal.cnn.layer.CustomClassificationLayer')...
            ||isa(ilayer{1},'nnet.internal.cnn.layer.ClassificationLayer');
        end



        function isSoftmaxLayer=isSoftmaxLayer(layer)




            isSoftmaxLayer=isa(layer,'nnet.cnn.layer.SoftmaxLayer');
        end

    end

end