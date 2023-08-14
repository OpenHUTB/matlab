function tree_collapsenodes(h,nodes)




    n=length(nodes);
    for i=1:n;
        child=nodes(i);
        if(child.isHierarchical)
            h.imme.collapseTreeNode(child);
            childnodes=child.getHierarchicalChildren;
            if(length(childnodes)>0)
                h.tree_collapsenodes(childnodes);
            end
        end
    end

