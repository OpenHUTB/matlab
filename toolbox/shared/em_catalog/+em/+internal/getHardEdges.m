function hard_edges=getHardEdges(hard_nodes,edges)
    hard_edges=[];
    new_edges=unique(sort(edges,2),'row');
    for i=1:max(size(new_edges))
        edge_in=new_edges(i,1)==hard_nodes(:)|...
        new_edges(i,2)==hard_nodes(:);
        if(sum(edge_in)==2)
            hard_edges=[hard_edges;new_edges(i,:)];
        end
    end
    hard_edges=hard_edges';
end