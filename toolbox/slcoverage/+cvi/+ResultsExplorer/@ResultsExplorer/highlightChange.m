function highlightChange(obj,node,add)



    if add
        obj.highlightedNode=node;
    else
        obj.highlightedNode=[];
    end



    obj.dataChange(node);
end