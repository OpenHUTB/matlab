function mRanks=calculateRanks(adjList)







    numNodes=length(adjList);
    preds=Advisor.Utils.Graph.getPredecessors(adjList);
    sucss=Advisor.Utils.Graph.getSuccessors(adjList);

    mRanks=ones(1,numNodes);


    g=matlab.internal.graph.MLDigraph(adjList);


    sources=find(arrayfun(@(x)isempty(preds{x}),1:numNodes))';
    sinks=find(arrayfun(@(x)isempty(sucss{x}),1:numNodes))';


    sinks=setdiff(sinks,sources);


    [~,~,layers]=g.layeredLayout(sources,sinks,'auto');


    for i=1:length(layers)
        nodesInLayer=layers{i};
        for j=1:numel(nodesInLayer)


            if nodesInLayer(j)<=numNodes
                mRanks(nodesInLayer(j))=i;
            end
        end
    end

end
