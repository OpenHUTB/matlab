function parentRow=createOrGetParentRow(modelName,parentPathInModel,createModelInfoArgs)







    fullNameToRowMap=createModelInfoArgs.FullNameToRowMap;

    if fullNameToRowMap.isKey(parentPathInModel)
        parentRow=fullNameToRowMap(parentPathInModel);
    else
        if isempty(parentPathInModel)
            parentRow=[];
        else
            grandParentPathInModel=Simulink.variant.utils.replaceNewLinesWithSpaces(...
            get_param(parentPathInModel,'Parent'));
            if isempty(grandParentPathInModel)
                grandParentRow=[];
            else
                grandParentRow=Simulink.variant.manager.hrow.createOrGetParentRow(...
                modelName,grandParentPathInModel,createModelInfoArgs);
            end

            vmBlockType=Simulink.variant.manager.VariantManagerBlockType.SubSystem;
            parentRow=Simulink.variant.manager.hrow.createVariantManagerHierarchyRow(...
            modelName,grandParentRow,parentPathInModel,createModelInfoArgs,vmBlockType);
        end
    end
end
