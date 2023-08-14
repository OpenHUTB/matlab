function bool=machineIsOpen(obj,machineId)




    if obj.logger
        disp(mfilename);
    end


    if machineId==-1
        bool=true;
        return;
    end

    bool=~isempty(sf('find','all','machine.id',machineId));