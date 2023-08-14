function edge=findEdge(obj,toEvolution,fromEvolution)




    edge=evolutions.model.Edge.empty(1,0);
    for idx=1:numel(obj.Infos)
        candidateEdge=obj.Infos(idx);
        nodes=candidateEdge.Nodes.toArray;
        if ismember(toEvolution,nodes)&&ismember(fromEvolution,nodes)
            edge=candidateEdge;
            break;
        end
    end
end
