function modelName=getModelNameFromPath(blockPathParentModel)











    pathsInHierarchy=Simulink.variant.utils.splitPathInHierarchy(blockPathParentModel);
    modelName=pathsInHierarchy{1};
end
