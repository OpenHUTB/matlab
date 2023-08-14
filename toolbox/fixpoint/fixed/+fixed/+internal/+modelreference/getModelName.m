function modelName=getModelName(modelBlockID)


















    modelName='';
    if fixed.internal.modelreference.isModelReference(modelBlockID)
        modelFileName=get_param(modelBlockID,'ModelFile');
        [~,modelName,~]=fileparts(modelFileName);
    end
end