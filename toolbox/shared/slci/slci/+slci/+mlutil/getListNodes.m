

function aList=getListNodes(head)
    assert(isa(head,'mtree'),'Input must be an mtree node');
    nodes=list(head);
    ind=nodes.indices;
    assert(numel(ind)>0);
    aList=cell(1,numel(ind));
    for k=1:numel(ind)
        aList{1,k}=select(nodes,ind(k));
    end
end
