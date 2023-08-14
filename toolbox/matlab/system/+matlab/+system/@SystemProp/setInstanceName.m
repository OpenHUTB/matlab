function setInstanceName(obj,name)
    validateInstanceName(obj,name);
    node=obj.GraphNode;
    if isempty(node)
        node=dataflow.internal.allocateNode(obj);
    end
    setName(node,name);
end

