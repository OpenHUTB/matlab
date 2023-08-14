function name=getInstanceName(obj)
    node=obj.GraphNode;
    if isempty(node)
        name='';
    else
        name=getName(node);
    end
end
