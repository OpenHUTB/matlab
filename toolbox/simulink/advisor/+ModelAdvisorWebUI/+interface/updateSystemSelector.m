function resultJSON=updateSystemSelector(rootAnalyzeID,componentsIds)

    appID=ModelAdvisorWebUI.interface.registerModel([{rootAnalyzeID},componentsIds(:)'],'MF');
    json=jsonencode(appID);
    result=struct('success',true,'message',jsonencode(struct('title','','content','')),'warning',false,'filepath','','value',json);
    resultJSON=jsonencode(result);
end