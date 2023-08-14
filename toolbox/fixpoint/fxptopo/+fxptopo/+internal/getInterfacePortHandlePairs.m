function pairsObject=getInterfacePortHandlePairs(blockPath)






    container=fxptopo.internal.TransformTopologyContainer();
    container.ChildContainer=fxptopo.internal.SLTopoContainer();
    container.TransformationObjects=[...
    fxptopo.internal.transformation.DeleteEdgeType("Contain");...
    fxptopo.internal.transformation.DeleteEdgeType("InterfaceIn");...
    fxptopo.internal.transformation.DeleteEdgeType("InterfaceOut");...
    ];
    container.buildGraph(bdroot(blockPath));

    inputPortHandlePair=[];
    outputPortHandlePair=[];

    blockNode=find(container.Graph.Nodes.Handle==get_param(blockPath,'Handle'));

    blockInportNodes=container.Graph.Edges.EndNodes(container.Graph.inedges(blockNode),1);
    for ii=1:numel(blockInportNodes)
        portNodesDrivingBlockInportNodes=arrayfun(@(x)container.Graph.Edges.EndNodes(container.Graph.inedges(x),1),blockInportNodes(ii),'UniformOutput',false);
        portNodesDrivingBlockInportNodes=cell2mat(portNodesDrivingBlockInportNodes);
        inputPortHandlePair=[inputPortHandlePair;[portNodesDrivingBlockInportNodes,repmat(blockInportNodes(ii),numel(portNodesDrivingBlockInportNodes),1)]];%#ok<AGROW>
    end
    inputPortHandlePair=reshape(container.Graph.Nodes.Handle(inputPortHandlePair(:)),size(inputPortHandlePair));

    blockOutportNodes=container.Graph.Edges.EndNodes(container.Graph.outedges(blockNode),2);
    for ii=1:numel(blockOutportNodes)
        portNodesDrivenByBlockOutportNodes=arrayfun(@(x)container.Graph.Edges.EndNodes(container.Graph.outedges(x),2),blockOutportNodes(ii),'UniformOutput',false);
        portNodesDrivenByBlockOutportNodes=cell2mat(portNodesDrivenByBlockOutportNodes);
        outputPortHandlePair=[outputPortHandlePair;[repmat(blockOutportNodes(ii),numel(portNodesDrivenByBlockOutportNodes),1),portNodesDrivenByBlockOutportNodes]];%#ok<AGROW>
    end
    outputPortHandlePair=reshape(container.Graph.Nodes.Handle(outputPortHandlePair(:)),size(outputPortHandlePair));

    pairsObject=fxptopo.internal.InterfacePortHandlePairsContainer(blockPath,inputPortHandlePair,outputPortHandlePair);
end
