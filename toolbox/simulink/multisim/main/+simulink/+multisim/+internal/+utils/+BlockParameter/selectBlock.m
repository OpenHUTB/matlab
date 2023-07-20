function selectBlock(dataModel,blockElement,modelHandle)
    modelName=get_param(modelHandle,"Name");
    bindModeSourceObj=BindMode.MultiSimBlockSelectorSourceData(modelName,dataModel,blockElement);
    BindMode.BindMode.enableBindMode(bindModeSourceObj);
end