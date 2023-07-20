function unpopulate(handle)



    if~isempty(handle.children)

        for idx=1:length(handle.children)
            delete(handle.children(idx));
        end

        handle.children=[];
    end