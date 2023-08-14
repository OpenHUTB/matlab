function sibling=findSibling(this,req)%#ok<INUSL>






    sibling=[];
    parent=req.parent;
    if isempty(parent)

        rootItems=req.requirementSet.rootItems;
        index=rootItems.indexOf(req);
        if index>1
            sibling=rootItems.at(index-1);
        end
    else
        index=parent.children.indexOf(req);
        if index>1
            sibling=parent.children.at(index-1);
        end
    end
end
