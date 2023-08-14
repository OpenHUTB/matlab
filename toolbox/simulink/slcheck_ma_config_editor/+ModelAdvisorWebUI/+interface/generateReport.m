function generateReport(modelID,fullID)

    appObj=Advisor.Manager.getApplication('id',modelID);
    targetObj=appObj.getMAObjs{1,1};
    selectedNode=targetObj.getTaskObj(fullID);
    exportReport(selectedNode);
end
