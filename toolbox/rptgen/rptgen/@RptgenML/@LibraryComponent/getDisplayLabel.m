function dLabel=getDisplayLabel(dao)




    dLabel=dao.DisplayName;
    if~isempty(dao.ComponentInstance)
        try
            dLabel=getName(dao.ComponentInstance);
        end
    end

    dLabel=['   ',dLabel];

