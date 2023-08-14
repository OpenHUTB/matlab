function varargout=plotCostGraph(aCostGraph,varargin)












    narginchk(1,2);


    if(size(varargin))
        aType=varargin{1};
    else
        aType="";
    end

    figure();
    aGraph=aCostGraph.Graph;
    fBlockNames=aGraph.Nodes.FullName;
    fBlockLabels=aGraph.Nodes.NodeLabel;
    switch aType
    case "Cost"
        aTotalCostArr=arrayfun(@(x)aCostGraph.getCost(x),fBlockNames);
        fDispayStr=fBlockLabels+": "+aTotalCostArr;
    case "TotalCost"
        aTotalCostArr=arrayfun(@(x)aCostGraph.getTotalCost(x),fBlockNames);
        fDispayStr=fBlockLabels+": "+aTotalCostArr;
    otherwise
        fDispayStr=fBlockLabels;
    end


    h=plot(aGraph,'NodeLabel',fDispayStr,'EdgeColor','r',...
    'NodeColor','b','Layout','layered','Direction','down','LineWidth',4,'Interpreter','none');

    h.UserData=aGraph;
    h.Parent.Parent.WindowButtonDownFcn=@fxptopo.internal.topoPlotCallback;

    if nargout>0
        varargout{1}=h;
    end
end


