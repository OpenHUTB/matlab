function open(node)
    handlers=dependencies.internal.Registry.Instance.NodeHandlers';
    for handler=handlers
        if apply(handler.NodeFilter,node)
            handler.open(node);
            return
        end
    end


    import dependencies.internal.graph.Type;
    if node.isFile()
        open(node.Location{1});
    end
end
