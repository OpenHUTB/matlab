function layers=getSortedLayers(obj)



    layers=[];
    if isa(obj,'SeriesNetwork')
        layers=obj.Layers;
    elseif isa(obj,'DAGNetwork')
        layers=obj.SortedLayers;
    elseif isa(obj,'dlnetwork')
        layers=obj.Layers(obj.TopologicalOrder);
    elseif isa(obj,'nnet.cnn.LayerGraph')
        obj=toposort(obj);
        topoOrder=obj.extractTopologicalOrder();
        layers=obj.Layers(topoOrder);
    end
end

