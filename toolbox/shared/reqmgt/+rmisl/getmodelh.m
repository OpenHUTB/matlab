function result=getmodelh(obj)






    [isSf,objH,~]=rmi.resolveobj(obj);

    if isSf
        result=rmisf.getmodelh(objH);
    elseif rmifa.isFaultInfoObj(objH)
        faultInfoObj=rmifa.resolveObjInFaultInfo(objH);
        result=get_param(faultInfoObj.getTopModelName,'handle');
    else
        result=get_param(bdroot(objH),'Handle');
    end



