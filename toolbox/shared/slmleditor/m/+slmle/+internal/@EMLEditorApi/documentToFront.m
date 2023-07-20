function bool=documentToFront(obj,objectId,requestFocus,sid)



    if obj.logger
        disp(mfilename);
    end

    bool=true;

    if sf('get',objectId,'.isa')==14

        return;
    else

        m=slmle.internal.slmlemgr.getInstance;
        blockH=slmle.internal.getBlockHandleFromSID(sid);
        m.open(objectId,blockH);
    end

