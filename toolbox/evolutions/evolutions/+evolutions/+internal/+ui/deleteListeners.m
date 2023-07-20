function deleteListeners(parent,listeners)




    assert(isstring(listeners));
    assert(~isempty(parent));
    for idx=1:numel(listeners)
        if~isempty(parent.(listeners(idx)))&&isvalid(parent.(listeners(idx)))
            parent.(listeners(idx)).Enabled=false;
            delete(parent.(listeners(idx)));
        end
    end
end