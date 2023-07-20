function tree_expandnodes(h,nodes)




    n=length(nodes);
    for i=1:n;
        child=nodes(i);
        if(child.isHierarchical)
            h.imme.expandTreeNode(child);
            childnodes=child.getHierarchicalChildren;
            if~isempty(childnodes)
                h.tree_expandnodes(childnodes);
            end
        end
    end

