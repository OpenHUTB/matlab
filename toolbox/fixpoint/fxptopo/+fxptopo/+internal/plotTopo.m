function varargout=plotTopo(topoGraph)











    figure();
    h=plot(topoGraph,'NodeLabel',topoGraph.Nodes.NodeLabel,'EdgeColor','b','NodeColor','k','Layout','layered','Direction','right','LineWidth',2);
    enums=enumeration('fxptopo.internal.EdgeType');
    nTypes=numel(enums);
    cData=(1:nTypes);
    h.EdgeCData=cData(arrayfun(@(x)find(x==enums),topoGraph.Edges.Type));
    if numel(unique(topoGraph.Edges.Type))>1
        h.EdgeLabel=arrayfun(@(x)char(x),topoGraph.Edges.Type,'UniformOutput',false);
    end
    h.UserData=topoGraph;
    p=parula(nTypes+floor(nTypes/4));
    firstColor=1;
    lastColor=firstColor+nTypes-1;
    h.Parent.Colormap=p(firstColor:lastColor,:);
    h.Parent.Parent.WindowButtonDownFcn=@fxptopo.internal.topoPlotCallback;

    if nargout>0
        varargout{1}=h;
    end
end


