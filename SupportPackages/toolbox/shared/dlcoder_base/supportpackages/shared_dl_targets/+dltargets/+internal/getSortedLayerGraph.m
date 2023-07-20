function sortedLayerGraph=getSortedLayerGraph(net)
%#codegen



    if isa(net,'SeriesNetwork')
        sortedLayerGraph=layerGraph(net.Layers);
    else
        sortedLayerGraph=layerGraph(net);
    end
    sortedLayerGraph=toposort(sortedLayerGraph);


end
