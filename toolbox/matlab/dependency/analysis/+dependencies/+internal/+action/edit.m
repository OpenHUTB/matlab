function restore=edit(node)




    restore=@()[];
    handlers=dependencies.internal.Registry.Instance.NodeHandlers';
    for handler=handlers
        if apply(handler.NodeFilter,node)
            restore=handler.edit(node);
            return
        end
    end

end
