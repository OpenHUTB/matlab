function connectNodeToInactiveList(target,node)









    if~isempty(node.up)
        disconnect(node)
    end
    target.inactiveList.connect(node,'down');
    if~isempty(node.data)
        node.data.inactivate(node,target)
    end


