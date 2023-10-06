function close(node)
    handlers=dependencies.internal.Registry.Instance.NodeHandlers';
    for handler=handlers
        if apply(handler.NodeFilter,node)
            handler.close(node);
            return
        end
    end

end

