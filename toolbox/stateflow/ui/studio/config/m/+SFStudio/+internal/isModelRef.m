function tf=isModelRef(cbInfo,machineName)











    model=cbInfo.referencedModel;
    if(isempty(model))
        model=cbInfo.model;
    end
    modelName=model.Name;
    tf=~strcmp(modelName,machineName);
end