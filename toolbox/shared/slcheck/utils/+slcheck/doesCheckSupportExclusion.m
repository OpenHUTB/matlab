function result=doesCheckSupportExclusion(modelName,checkID)









    result=false;
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(modelName);
    checkObj=mdladvObj.getCheckObj(checkID);

    if~isempty(checkObj)
        result=checkObj.SupportExclusion;
    end

end

