function resultJSON=getCheckData(checkid)

    if isempty(checkid)
        checkObjJSON=jsonencode(NaN);
    else
        maObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
        checkObj=maObj.getCheckObj(checkid);
        checkObjJSON=Advisor.Utils.exportJSON(checkObj,'MACE');
    end

    result=struct('success',true,'message',jsonencode(struct('title','','content','')),'warning',false,'filepath','','value',checkObjJSON);
    resultJSON=jsonencode(result);
end