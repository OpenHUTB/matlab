function networkInfo=convBatchNormLayerFusion(networkInfo,transformProperties)























    convBN=analyzeDLNetwork(networkInfo,transformProperties);

    if~isempty(convBN)

        xformedlgraph=xformNetwork(networkInfo,convBN,transformProperties);


        networkInfo.SortedLayerGraph=toposort(xformedlgraph);

        batchNormLayerNames=igetBatchNormNames(convBN);


        remove(networkInfo.LayerInfoMap,batchNormLayerNames);
    end


end

function batchNormLayerNames=igetBatchNormNames(convBN)

    convBN_pairs=values(convBN);
    batchNormLayerNames=cell(numel(convBN_pairs),1);
    for i=1:numel(convBN_pairs)
        convBNPair=convBN_pairs{i};
        batchNormNLayer=convBNPair{2};
        batchNormLayerNames{i}=batchNormNLayer.Name;

    end

end

function convBN=analyzeDLNetwork(networkInfo,transformProperties)










    layerArray=networkInfo.SortedLayerGraph.Layers;
    nameToLayerObj=dltargets.internal.optimizations.internal.getNameToLayerObjMap(layerArray);

    findConvBNPattern=@dltargets.internal.optimizations.internal.findConvBNPattern;

    convBN=dltargets.internal.optimizations.internal.breadthFirstSearch(...
    networkInfo.DiGraph,networkInfo.InputNames,...
    nameToLayerObj,findConvBNPattern,transformProperties);


end


function xformedlgraph=xformNetwork(networkInfo,convBN,transformProperties)

    convBNKeys=convBN.keys;

    xformedlgraph=networkInfo.SortedLayerGraph;
    for eachKey=convBNKeys
        xformedlgraph=applyPatternToDAG(...
        xformedlgraph,networkInfo,convBN(eachKey{:}),transformProperties);
    end

end

function lgraph=applyPatternToDAG(lgraph,networkInfo,convBN_Pair,transformProperties)




    convLayer=convBN_Pair{1};
    convLayerName=convLayer.Name;

    BNLayer=convBN_Pair{2};
    BNLayerName=BNLayer.Name;


    lgraph=replaceLayer(lgraph,convLayerName,[convLayer]);%#ok<*NBRAK>


    lgraph=disconnectLayers(lgraph,convLayerName,BNLayerName);



    connectivityMap=networkInfo.Connections;
    if iHasReceivingLayer(BNLayerName,connectivityMap)
        dstStruct=connectivityMap(BNLayerName);
        for i=1:numel(dstStruct)
            destination=[dstStruct(i).outputLayer,'/',dstStruct(i).destPortname];
            lgraph=disconnectLayers(lgraph,BNLayerName,destination);
            lgraph=connectLayers(lgraph,convLayerName,destination);
        end
    else





        networkInfo.updateOutputLayer(BNLayerName,convLayer);
    end

    lgraph=removeLayers(lgraph,BNLayerName);


    transformProperties.updateMap(convLayer,BNLayer);

end





function hasReceivingLayer=iHasReceivingLayer(layerName,connectivityMap)
    hasReceivingLayer=connectivityMap.isKey(layerName);
end
