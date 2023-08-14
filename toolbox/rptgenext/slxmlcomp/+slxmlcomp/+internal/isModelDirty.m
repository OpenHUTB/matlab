function isDirty=isModelDirty(modelPath)



    isDirty=false;
    dirtyModelPaths=slxmlcomp.internal.getOpenBlockDiagramFilePaths('dirty');
    if isempty(dirtyModelPaths)
        return
    end
    isDirty=any(ismember(dirtyModelPaths,modelPath));
end