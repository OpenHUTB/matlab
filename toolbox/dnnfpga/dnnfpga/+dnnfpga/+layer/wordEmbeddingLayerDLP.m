classdef wordEmbeddingLayerDLP<nnet.layer.Layer&nnet.layer.Formattable&dnnfpga.layer.NotCustomLayer


    properties(Hidden,Access=private)

ExecutionStrategy
    end
    properties
Dimension
NumWords
Weights
    end

    methods
        function layer=wordEmbeddingLayerDLP(wordEmbeddingLayer)



            layer.Dimension=wordEmbeddingLayer.Dimension;
            layer.NumWords=wordEmbeddingLayer.NumWords;
            layer.Weights=wordEmbeddingLayer.Weights;



            layer.Name=wordEmbeddingLayer.Name;


            layer.Description=['Word embedding layer with ',int2str(layer.Dimension),' dimensions and ',int2str(layer.NumWords),' unique words'];


            layer.Type="Word Embedding Layer";

            layer.ExecutionStrategy=...
            nnet.internal.cnn.layer.util.EmbeddingDAGNetworkStrategy();


        end

        function Z=predict(layer,X)

            XSeq=reshape(extractdata(X),[],1);
            ZSeq=layer.ExecutionStrategy.forward(XSeq,layer.Weights,layer.NumWords,layer.Dimension);
            Z=dlarray(reshape(ZSeq,1,1,[]));

        end
    end
end