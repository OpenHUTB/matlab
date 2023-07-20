function trainedNet=buildDAG(lgraph,targetNames)









































    haveDAGNetwork=iHaveDAGNetwork(lgraph);


    iValidateLayers(lgraph,haveDAGNetwork);

    if haveDAGNetwork
        lgraph=iInferParameters(lgraph,haveDAGNetwork);
        internalLayers=iGetInternalLayers(lgraph.Layers);
    else
        internalLayers=iGetInternalLayers(lgraph);
        internalLayers=iInferParameters(internalLayers,haveDAGNetwork);
    end


    layersMap=iLayersMap(lgraph,haveDAGNetwork);


    precision=nnet.internal.cnn.util.Precision('single');


    internalLayers=iInitializeParameters(internalLayers,precision);

    if nargin>1

        if iIsClassificationNetwork(internalLayers)
            internalLayers=iMaybeStoreClassNames(internalLayers,targetNames);
        else
            internalLayers=iStoreResponseNames(internalLayers,targetNames);
        end
    end


    trainedNet=iCreateInternalNetwork(lgraph,internalLayers,haveDAGNetwork);


    trainedNet=trainedNet.prepareNetworkForPrediction();
    trainedNet=trainedNet.setupNetworkForHostPrediction();


    trainedNet=iCreateExternalNetwork(trainedNet,layersMap,haveDAGNetwork);
end

function haveDAGNetwork=iHaveDAGNetwork(lgraph)
    haveDAGNetwork=isa(lgraph,'nnet.cnn.LayerGraph');
end

function iValidateLayers(layers,haveDAGNetwork)



    if haveDAGNetwork
        layers=layers.Layers;
    end

    if~isa(layers,'nnet.cnn.layer.Layer')
        error(message('nnet_cnn:trainNetwork:InvalidLayersArray'))
    end

    for ii=1:numel(layers)

        if~isa(layers(ii),'nnet.internal.cnn.layer.Externalizable')
            nnet.internal.cnn.layer.util.CustomLayerVerifier.validateMethodSignatures(layers(ii),ii);
        end
    end

    if iContainsLSTMLayers(layers)
        if iContainsRegressionLayers(layers)
            error(message('nnet_cnn:trainNetwork:RegressionNotSupportedForLSTM'))
        else
            tfArray=iContainsIncompatibleLayers(layers);
            if any(tfArray)
                incompatibleLayers=layers(tfArray);
                error(message('nnet_cnn:trainNetwork:IncompatibleLayers',...
                class(incompatibleLayers(1))))
            end
        end
    end
end

function lgraph=iInferParameters(lgraph,haveDAGNetwork)
    if haveDAGNetwork

        lgraph=inferParameters(lgraph);
    else

        lgraph=nnet.internal.cnn.layer.util.inferParameters(lgraph);
    end
end

function internalLayers=iGetInternalLayers(layers)
    internalLayers=nnet.internal.cnn.layer.util.ExternalInternalConverter.getInternalLayers(layers);
end

function internalNetwork=iCreateInternalNetwork(lgraph,internalLayers,haveDAGNetwork)
    if haveDAGNetwork
        internalLayerGraph=iExternalToInternalLayerGraph(lgraph);
        internalLayerGraph.Layers=internalLayers;
        topologicalOrder=extractTopologicalOrder(lgraph);
        internalNetwork=nnet.internal.cnn.DAGNetwork(internalLayerGraph,topologicalOrder);
    else
        internalNetwork=nnet.internal.cnn.SeriesNetwork(internalLayers);
    end
end

function externalNetwork=iCreateExternalNetwork(internalNetwork,layersMap,haveDAGNetwork)



    if haveDAGNetwork
        externalNetwork=DAGNetwork(internalNetwork,layersMap);
    else


        externalNetwork=SeriesNetwork(internalNetwork.Layers,layersMap);


        externalNetwork=externalNetwork.resetState();
    end
end

function internalLayerGraph=iExternalToInternalLayerGraph(externalLayerGraph)
    internalLayers=iGetInternalLayers(externalLayerGraph.Layers);
    hiddenConnections=externalLayerGraph.HiddenConnections;
    internalConnections=iHiddenToInternalConnections(hiddenConnections);
    internalLayerGraph=nnet.internal.cnn.LayerGraph(internalLayers,internalConnections);
end

function internalConnections=iHiddenToInternalConnections(hiddenConnections)
    internalConnections=nnet.internal.cnn.util.hiddenToInternalConnections(hiddenConnections);
end

function tf=iContainsLSTMLayers(layers)
    tf=any(arrayfun(@(l)isa(l,'nnet.cnn.layer.LSTMLayer'),layers));
end

function layersMap=iLayersMap(layers,haveDAGNetwork)
    if haveDAGNetwork
        layers=layers.Layers;
    end

    layersMap=nnet.internal.cnn.layer.util.InternalExternalMap(layers);
end

function layers=iInitializeParameters(layers,precision)
    for i=1:numel(layers)
        layers{i}=layers{i}.initializeLearnableParameters(precision);
        if isa(layers{i},'nnet.internal.cnn.layer.LSTM')
            layers{i}=layers{i}.initializeDynamicParameters(precision);
        end
    end
end

function tf=iIsClassificationNetwork(internalLayers)
    tf=iIsClassificationLayer(internalLayers{end});
end

function tf=iIsClassificationLayer(internalLayer)
    tf=isa(internalLayer,'nnet.internal.cnn.layer.ClassificationLayer');
end

function layers=iMaybeStoreClassNames(layers,classNames)

    shouldSetClassNames=isempty(layers{end}.ClassNames);
    if shouldSetClassNames
        layers=iStoreClassNames(layers,classNames);
    end
end

function layers=iStoreClassNames(layers,labels)
    layers{end}.ClassNames=labels;
end

function layers=iStoreResponseNames(layers,responseNames)
    layers{end}.ResponseNames=responseNames;
end
