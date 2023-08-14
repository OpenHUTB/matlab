












































function areLayersBetweenFoldAndUnfold=checkIfFolded(lgraph,sortedLayerIndices,isCustomCoderLayerGraph)




    coder.allowpcode('plain');


    dgraph=lgraph.extractPrivateDirectedGraph;

    layerArray=lgraph.Layers;

    areLayersBetweenFoldAndUnfold=iCheckIfBetweenFoldAndUnfold(layerArray,...
    dgraph,sortedLayerIndices,isCustomCoderLayerGraph);
end

function areLayersBetweenFoldAndUnfold=iCheckIfBetweenFoldAndUnfold(layerArray,directedGraph,layerIndices,isCustomCoderLayerGraph)





















    [sequenceFoldingClassName,sequenceUnfoldingClassName]=iGetFoldAndUnfoldLayerClassNames(isCustomCoderLayerGraph);

    numLayerIndices=numel(layerIndices);






    layersBetweenFoldAndUnfoldCache=dictionary(string.empty,logical.empty);

    areLayersBetweenFoldAndUnfold=false(1,numLayerIndices);

    for idxActivation=1:numLayerIndices
        activationLayerIdx=layerIndices(idxActivation);
        activationLayerName=layerArray(activationLayerIdx).Name;
        predecessorLayerIdx=activationLayerIdx;
        while~isempty(predecessorLayerIdx)

            predecessorLayerIdx=predecessorLayerIdx(1);
            predecessorLayer=layerArray(predecessorLayerIdx);
            predecessorLayerName=predecessorLayer.Name;
            if isKey(layersBetweenFoldAndUnfoldCache,predecessorLayerName)

                areLayersBetweenFoldAndUnfold(idxActivation)=layersBetweenFoldAndUnfoldCache(predecessorLayerName);
                layersBetweenFoldAndUnfoldCache(activationLayerName)=layersBetweenFoldAndUnfoldCache(predecessorLayerName);
                break
            elseif isa(predecessorLayer,sequenceUnfoldingClassName)


                layersBetweenFoldAndUnfoldCache(activationLayerName)=false;
                break
            elseif isa(predecessorLayer,sequenceFoldingClassName)


                areLayersBetweenFoldAndUnfold(idxActivation)=true;
                layersBetweenFoldAndUnfoldCache(activationLayerName)=true;
                break
            else

                predecessorLayerIdx=directedGraph.predecessors(predecessorLayerIdx);
                if isempty(predecessorLayerIdx)


                    layersBetweenFoldAndUnfoldCache(activationLayerName)=false;
                end
            end
        end
    end
end

function[sequenceFoldingClassName,sequenceUnfoldingClassName]=iGetFoldAndUnfoldLayerClassNames(isCustomCoderLayerGraph)



    if isCustomCoderLayerGraph
        sequenceFoldingClassName='coder.internal.layer.SequenceFoldingLayer';
        sequenceUnfoldingClassName='coder.internal.layer.SequenceUnfoldingLayer';
    else
        sequenceFoldingClassName='nnet.cnn.layer.SequenceFoldingLayer';
        sequenceUnfoldingClassName='nnet.cnn.layer.SequenceUnfoldingLayer';
    end

end
