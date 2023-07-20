function G=extractBDTopoGraph(bd)


    load_system(bd);
    edges=bdTopoEdges(get_param(bd,'handle'));



    nodes.hier=unique(edges.hier(:));
    nodes.oport=unique(edges.b2op(:,2));
    nodes.iport=unique(edges.ip2b(:,1));


    allnodes=[
    nodes.hier
    nodes.oport
    nodes.iport
    ];

    nodeTable=table(allnodes,'VariableNames',{'Handle'});


    alledges=[
    toIndex(allnodes,edges.hier)
    toIndex(allnodes,edges.conn)
    toIndex(allnodes,edges.b2op)
    toIndex(allnodes,edges.ip2b)
    toIndex(allnodes,edges.ifaceOut)
    toIndex(allnodes,edges.ifaceIn)
    ];



    import Simulink.internal.TopoEdge
    edgeType=[
    repmat(TopoEdge.Contain,[size(edges.hier,1),1])
    repmat(TopoEdge.Signal,[size(edges.conn,1),1])
    repmat(TopoEdge.BlockPortOut,[size(edges.b2op,1),1])
    repmat(TopoEdge.BlockPortIn,[size(edges.ip2b,1),1])
    repmat(TopoEdge.InterfaceIn,[size(edges.ifaceIn,1),1])
    repmat(TopoEdge.InterfaceOut,[size(edges.ifaceOut,1),1])
    ];

    edgeTable=table(alledges,edgeType,...
    'VariableNames',{'EndNodes','Type'});


    G=digraph(edgeTable,nodeTable);

end


function I=toIndex(baseline,input)
    [~,I]=ismember(input,baseline);
end
