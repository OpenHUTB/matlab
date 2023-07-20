function[inportSIDs,outportSIDs]=getInternalPortsForSubSystem(subSystemPath)






    container=fxptopo.internal.TransformTopologyContainer();
    container.ChildContainer=fxptopo.internal.SLTopoContainer();
    container.TransformationObjects=fxptopo.internal.transformation.DeleteEdgeType("Contain");
    container.buildGraph(subSystemPath);

    subSystemNode=find(strcmp(container.Graph.Nodes.SID,Simulink.ID.getSID(subSystemPath)));

    inNodes=container.Graph.Edges.EndNodes(container.Graph.inedges(subSystemNode),1);
    allEdgesToInPort=[];
    for ii=1:numel(inNodes)
        allEdgesToInPort=[allEdgesToInPort;container.Graph.Edges.EndNodes(container.Graph.outedges(inNodes(ii)),:)];%#ok<AGROW>
        allEdgesToInPort=[allEdgesToInPort;container.Graph.Edges.EndNodes(container.Graph.inedges(inNodes(ii)),:)];%#ok<AGROW>
    end
    potentialInportBlockNodes=allEdgesToInPort(arrayfun(@(x)all(x~=inNodes),allEdgesToInPort(:)));
    inportSIDs=container.Graph.Nodes.SID(potentialInportBlockNodes(strcmp(container.Graph.Nodes.Type(potentialInportBlockNodes),'Inport')));
    inportSIDs=inportSIDs(:);

    outNodes=container.Graph.Edges.EndNodes(container.Graph.outedges(subSystemNode),2);
    allEdgesToOutPort=[];
    for ii=1:numel(outNodes)
        allEdgesToOutPort=[allEdgesToOutPort;container.Graph.Edges.EndNodes(container.Graph.outedges(outNodes(ii)),:)];%#ok<AGROW>
        allEdgesToOutPort=[allEdgesToOutPort;container.Graph.Edges.EndNodes(container.Graph.inedges(outNodes(ii)),:)];%#ok<AGROW>
    end
    potentialOutportBlockNodes=allEdgesToOutPort(arrayfun(@(x)all(x~=outNodes),allEdgesToOutPort(:)));
    outportSIDs=container.Graph.Nodes.SID(potentialOutportBlockNodes(strcmp(container.Graph.Nodes.Type(potentialOutportBlockNodes),'Outport')));
    outportSIDs=outportSIDs(:);
end
