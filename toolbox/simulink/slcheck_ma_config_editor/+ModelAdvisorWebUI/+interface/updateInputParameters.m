function updateInputParameters(modelId,checkId,index,value)

    appObj=Advisor.Manager.getApplication('id',modelId);
    obj.targetObj=appObj.getMAObjs{1,1};
    selectedNode=obj.targetObj.getTaskObj(checkId);
    inputParas=selectedNode.check.getInputParameters;
    inputParas{1,index}.Value=value;
    selectedNode.check.setInputParameters(inputParas);
    selectedCheck=selectedNode.check;

end