function bool=documentOpen(obj,...
    int_activeMachineId,...
    int_parentMachineId,...
    objectId,...
    bool_isBlock,...
    bool_isTruthTable,...
    bool_isStateflowApp,...
    bool_isDESVariant,...
    str_title,...
    str_shortName,...
    str_text,...
    int_x,int_y,int_w,int_h,...
    str_fileName,...
    str_uniqueId,...
    sid)


    if obj.logger
        disp(mfilename);
    end

    bool=true;

    if sf('get',objectId,'.isa')==14

        edit(str_fileName);
    else
        m=slmle.internal.slmlemgr.getInstance;
        blockH=slmle.internal.getBlockHandleFromSID(sid);
        m.open(objectId,blockH);
    end





