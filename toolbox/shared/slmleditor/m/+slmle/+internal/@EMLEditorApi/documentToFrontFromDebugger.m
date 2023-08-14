function bool=documentToFrontFromDebugger(obj,objectId,sid)



    if obj.logger
        disp(mfilename);
    end

    bool=true;
    objType=sf('get',objectId,'.isa');
    if objType==sf('get','default','script.isa')
        filePath=sf('get',objectId,'.filePath');
        edit(filePath);
    else

        m=slmle.internal.slmlemgr.getInstance;
        blockH=slmle.internal.getBlockHandleFromSID(sid);
        m.open(objectId,blockH);





        obj.documentSetLock(objectId,true);
    end

