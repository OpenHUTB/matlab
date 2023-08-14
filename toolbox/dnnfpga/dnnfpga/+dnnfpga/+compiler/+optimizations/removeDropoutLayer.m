function xformedNet=removeDropoutLayer(net)













    idsToRemove=getLayersIDs(net,'nnet.cnn.layer.DropoutLayer');

    if~isempty(idsToRemove)
        switch class(net)
        case 'SeriesNetwork'
            xformedNet=xformSeriesNetwork(net,idsToRemove);
        case 'DAGNetwork'
            xformedNet=xformDAGNetwork(net,idsToRemove);
        case 'dlnetwork'
            xformedNet=xformDLNetwork(net,idsToRemove);
        end
    else
        xformedNet=net;
    end

end


function idsToRemove=getLayersIDs(net,layertype)






    fn=@(x)isa(x,layertype);
    arr=arrayfun(fn,net.Layers);
    idsToRemove=find(arr);
end

function xformedNet=xformSeriesNetwork(net,idsToRemove)







    layerArray=net.Layers;
    layerArray(idsToRemove)=[];
    xformedNet=assembleNetwork(layerArray);
end

function xformedNet=xformDAGNetwork(net,idsToRemove)







    lgraph=net.layerGraph;
    lgraphMod=xformLGraph(lgraph,idsToRemove);
    xformedNet=assembleNetwork(lgraphMod);
end

function xformedNet=xformDLNetwork(net,idsToRemove)







    lgraph=net.layerGraph;
    lgraphMod=xformLGraph(lgraph,idsToRemove);
    xformedNet=dlnetwork(lgraphMod);
end

function lgraph=xformLGraph(lgraph,idsToRemove)







    layers=lgraph.Layers;
    connections=lgraph.Connections;

    for i=1:numel(idsToRemove)
        index=idsToRemove(i);


        lgraph=removeLayers(lgraph,layers(index).Name);

        l=strcmp(connections.Destination,layers(index).Name);
        source=connections{l,'Source'};

        indices=find(strcmp(connections.Source,layers(index).Name));
        for j=1:numel(indices)

            destination=connections{indices(j),'Destination'};

            lgraph=connectLayers(lgraph,source{:},destination{:});
        end
    end
end
