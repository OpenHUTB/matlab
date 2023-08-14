function rootModelPath=convertBlockPathObjectToRootModelPath(blockPathObject)






    if isa(blockPathObject,'Simulink.BlockPath')
        blockPathsCell=blockPathObject.convertToCell();
        rootModelPath=blockPathsCell{1};
        for i=2:numel(blockPathsCell)

            subsystemBlocksInHierarchy=Simulink.variant.utils.splitPathInHierarchy(blockPathsCell{i});
            rootModelPath=[rootModelPath,'/',strjoin(subsystemBlocksInHierarchy(2:end),'/')];%#ok<AGROW>
        end
    else

        rootModelPath=blockPathObject;
    end
end


