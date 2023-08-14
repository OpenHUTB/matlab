function enable=enableNextPreviousButton(obj,set)




    if isempty(set)
        enable=obj.enableNextPrevious;
        return;
    end

    if~isequal(obj.enableNextPrevious,set)
        obj.enableNextPrevious=set;
    end
    enable=obj.enableNextPrevious;
