function layers=getSortedLayers(net)
    if isa(net,'SeriesNetwork')
        layers=net.Layers;
    elseif isa(net,'DAGNetwork')
        layers=net.SortedLayers;
    elseif isa(net,'dlnetwork')
        layers=net.Layers(net.TopologicalOrder);
    end
end
