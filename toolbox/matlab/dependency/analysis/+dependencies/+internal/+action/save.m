function save(node)




    handlers=dependencies.internal.Registry.Instance.NodeHandlers';
    for handler=handlers
        if apply(handler.NodeFilter,node)
            handler.save(node);
            return
        end
    end

end

