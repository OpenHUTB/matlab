function deleteControllers(parent,controllers)




    assert(isstring(controllers));
    assert(~isempty(parent));
    for idx=1:numel(controllers)
        if~isempty(parent.(controllers(idx)))&&isvalid(parent.(controllers(idx)))
            delete(parent.(controllers(idx)));
        end
    end
end
