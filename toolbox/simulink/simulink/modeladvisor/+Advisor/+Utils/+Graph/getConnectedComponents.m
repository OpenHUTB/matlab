function[SCC,I]=getConnectedComponents(adjList)

    [SCC,I]=conncomp(digraph((adjList)),'Type','weak');
end