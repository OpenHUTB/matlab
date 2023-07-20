function bool=machineSetDirty(obj,machineId,makeDirty)


    if obj.logger
        disp(mfilename);
    end


    modelH=sf('get',machineId,'machine.simulinkModel');

    if makeDirty
        makeDirty='on';
    else
        makeDirty='off';
    end

    isDirty=get_param(modelH,'dirty');
    if~strcmp(isDirty,makeDirty)
        set_param(modelH,'dirty',makeDirty);
    end

    bool=true;

