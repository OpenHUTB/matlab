function tempFailObj=prepareFailureObject(uddObj,recAction,status)
    tempFailObj=ModelAdvisor.ResultDetail;
    ModelAdvisor.ResultDetail.setData(tempFailObj,'SID',uddObj);
    tempFailObj.RecAction=recAction;
    tempFailObj.Status=status;
end