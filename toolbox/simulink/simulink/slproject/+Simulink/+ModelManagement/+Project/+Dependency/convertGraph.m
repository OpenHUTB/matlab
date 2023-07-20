function mlGraph=convertGraph(jContainer)




    javaGraph=jContainer.getDependencyGraph();
    checksumData=jContainer.getData('checksum');
    pathData=jContainer.getData('onPath');

    jVertices=javaGraph.getAllVertices().toArray();
    nodes=dependencies.internal.graph.Node.empty(1,0);
    for n=1:jVertices.length
        nodes(end+1)=convertVertex(jVertices(n));%#ok<AGROW> - that's actually quicker
        if~isempty(checksumData)
            nodes(end).setProperty("checksum",char(checksumData.transform(jVertices(n))));
        end
        if~isempty(pathData)
            nodes(end).setProperty("onPath",char(pathData.transform(jVertices(n))));
        end
    end

    deps=dependencies.internal.graph.Dependency.empty(1,0);
    jEdges=javaGraph.getAllEdges().toArray();
    for n=1:jEdges.length
        jEdge=jEdges(n);
        jUpVertex=javaGraph.getUpstreamVertex(jEdge);
        jDownVertex=javaGraph.getDownstreamVertex(jEdge);
        dep=convertEdge(jUpVertex,jDownVertex,jEdge);
        deps(end+1)=dep;%#ok<AGROW> - that's actually quicker
    end

    mlGraph=dependencies.internal.graph.Graph(nodes,deps);
end
