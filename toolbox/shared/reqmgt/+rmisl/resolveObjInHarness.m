function[isSf,objH,info]=resolveObjInHarness(harnessIdStr)








    objID=slreq.utils.getObjSidFromHarnessIdString(harnessIdStr);
    try
        objH=Simulink.ID.getHandle(objID);
    catch ex %#ok<NASGU>
        info=sprintf('%s',objID);
        isSf=[];
        objH=[];
        return;
    end

    if nargout>2


        [~,info]=rmi.objinfo(objH);
    end

    if isa(objH,'Stateflow.Object')
        objH=objH.Id;
        isSf=true;
    else
        isSf=false;
    end
end
