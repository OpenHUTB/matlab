function blockPathRootModel=getBlockPathRootModel(blockPathParentModel,rootPathPrefix)




    if isempty(rootPathPrefix)

        blockPathRootModel=blockPathParentModel;
    else
        refModelBlockPathParts=Simulink.variant.utils.splitPathInHierarchy(blockPathParentModel);
        blockPathRootModel=[rootPathPrefix,'/',strjoin(refModelBlockPathParts(2:end),'/')];
    end
end
