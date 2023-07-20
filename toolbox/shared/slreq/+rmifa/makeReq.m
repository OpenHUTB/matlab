function req=makeReq(target)





    req=rmi.createEmptyReqs(1);
    req.reqsys='linktype_rmi_simulink';

    targetObj=rmifa.resolveObjInFaultInfo(target);

    req.doc=targetObj.getTopModelName();
    req.id=[rmifa.itemIDPref,targetObj.Uuid];
    req.description=rmifa.getDisplayString(targetObj);
end
