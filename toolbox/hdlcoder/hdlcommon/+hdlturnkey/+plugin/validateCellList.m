function validateCellList(list,msgObj)




    if~iscell(list)||...
        (~isempty(list)&&~ischar(list{1}))
        error(msgObj);
    end

end