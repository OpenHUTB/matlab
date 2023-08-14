function[SCC,I]=getStronglyConnectedComponents(adjList)

    [SCC,I]=conncomp(digraph((adjList)));
end