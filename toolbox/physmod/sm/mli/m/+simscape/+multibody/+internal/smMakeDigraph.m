function graph=smMakeDigraph(nodeNames,edgeEndNodes,otherNodeVars,otherEdgeVars,varargin)












































    numOtherNodeVars=numel(otherNodeVars);
    numOtherEdgeVars=numel(otherEdgeVars);


    nodeTable=table(nodeNames,'VariableNames',["Name"]);
    for i=1:numOtherNodeVars
        nodeTable.(otherNodeVars{i})=varargin{i};
    end


    edgeTable=table(edgeEndNodes,'VariableNames',["EndNodes"]);
    for i=1:numOtherEdgeVars
        edgeTable.(otherEdgeVars{i})=varargin{numOtherNodeVars+i};
    end


    graph=digraph(edgeTable,nodeTable);

end


