function addEdge(obj,toEvolution,fromEvolution)





    if~isempty(fromEvolution)

        edge=obj.create(toEvolution,fromEvolution);


        fromEvolution.addChild(edge);


        obj.insert(edge);
    end
end
