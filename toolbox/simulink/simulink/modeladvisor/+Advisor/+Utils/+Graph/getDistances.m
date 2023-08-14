function dists=getDistances(adjList)
    dig=digraph(adjList);
    dists=dig.distances();
end