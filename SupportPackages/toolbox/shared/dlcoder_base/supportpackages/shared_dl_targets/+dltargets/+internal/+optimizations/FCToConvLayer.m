function networkInfo=FCToConvLayer(networkInfo,FCBNReLUxformFlag)













    FCToConv=analyzeDLNetwork(networkInfo,FCBNReLUxformFlag);

    if~isempty(FCToConv)

        xformedlgraph=xformNetwork(networkInfo,FCToConv);


        networkInfo.SortedLayerGraph=toposort(xformedlgraph);

    end


end


function[FCToConv]=analyzeDLNetwork(networkInfo,FCBNReLUxformFlag)












    layerArray=networkInfo.SortedLayerGraph.Layers;
    nameToLayerObj=dltargets.internal.optimizations.internal.getNameToLayerObjMap(layerArray);
    findFC=@dltargets.internal.optimizations.internal.findFC;

    FCToConv=dltargets.internal.optimizations.internal.breadthFirstSearch(...
    networkInfo.DiGraph,...
    networkInfo.InputNames,...
    nameToLayerObj,...
    findFC,...
    FCBNReLUxformFlag);


end


function xformedlgraph=xformNetwork(networkInfo,FCToConv)

    FCToConvKeys=FCToConv.keys;
    xformedlgraph=networkInfo.SortedLayerGraph;

    for eachKey=FCToConvKeys
        xformedlgraph=applyPatternToDAG(xformedlgraph,FCToConv(eachKey{:}));
    end

end

function lGraph=applyPatternToDAG(lGraph,convLayer)

    FCLayerName=convLayer.Name;


    lGraph=replaceLayer(lGraph,FCLayerName,[convLayer]);%#ok<*NBRAK>

end





