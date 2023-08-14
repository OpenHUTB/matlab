function resultJSON=initMACEObj(appID)
    am=Advisor.Manager.getInstance;
    appObj=am.getApplication('ID',appID);
    maObj=appObj.getRootMAObj;

    Simulink.ModelAdvisor.getActiveModelAdvisorObj(maObj);
    Simulink.ModelAdvisor.openConfigUI('initializeOnly');
    result=struct('success',true,'message',jsonencode(struct('title','','content','')),'warning',false,'filepath','','value',jsonencode('success'));
    resultJSON=jsonencode(result);
end