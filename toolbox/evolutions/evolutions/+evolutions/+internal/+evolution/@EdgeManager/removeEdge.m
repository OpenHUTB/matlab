function removeEdge(obj,toEvolution,fromEvolution)






    if~isempty(fromEvolution)

        edge=obj.findEdge(toEvolution,fromEvolution);

        fromEvolution.removeChild(edge);

        edge.decrement;
    end
end
