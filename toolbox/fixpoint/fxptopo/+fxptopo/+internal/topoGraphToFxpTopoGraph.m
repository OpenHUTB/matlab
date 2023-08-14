function fxpTopoGraph=topoGraphToFxpTopoGraph(topoGraph)




    edgeTable=topoGraph.Edges;
    edgeTable.Type=fxptopo.internal.EdgeType(string(edgeTable.Type));
    nodeTable=topoGraph.Nodes;
    fxpTopoGraph=digraph(edgeTable,nodeTable);

    fxpTopoGraph.Nodes.Type=string(get_param(fxpTopoGraph.Nodes.Handle,'Type'));
    fxpTopoGraph.Nodes.SID=string(Simulink.ID.getSID(fxpTopoGraph.Nodes.Handle));
    blockIndices=fxpTopoGraph.Nodes.Type=="block";
    blockSIDs=fxpTopoGraph.Nodes.SID(blockIndices);
    fxpTopoGraph.Nodes.Type(blockIndices)=get_param(blockSIDs,'BlockType');
    fxpTopoGraph.Nodes.NodeLabel=string(get_param(fxpTopoGraph.Nodes.Handle,'Name'));
    fxpTopoGraph.Nodes.MaskType(blockIndices)=string(get_param(blockSIDs,'MaskType'));
    fxpTopoGraph.Nodes.IsLink(blockIndices)=~contains(get_param(blockSIDs,'LinkStatus'),{'none','inactive'});


    mdlRefNodes=find(fxpTopoGraph.Nodes.Type=="ModelReference");
    mdlRefHandles=fxpTopoGraph.Nodes.Handle(mdlRefNodes);
    nMdlRef=numel(mdlRefHandles);
    for ii=1:nMdlRef
        modelName=fixed.internal.modelreference.getModelName(mdlRefHandles(ii));
        fxpTopoGraph.Nodes.NodeLabel(mdlRefNodes(ii))=string(modelName);
    end
end


