function g=getParentGraph(obj)
    node=obj.GraphNode;
    if isempty(node)
        g=dataflow.Graph.empty;
    else
        g=getParent(node);
    end
end
