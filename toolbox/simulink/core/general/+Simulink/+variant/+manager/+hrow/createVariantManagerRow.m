function parentRow=createVariantManagerRow(modelName,blockPath,createModelInfoArgs)




    parentBlockPath=Simulink.variant.utils.replaceNewLinesWithSpaces(get_param(blockPath,'Parent'));


    parentRow=Simulink.variant.manager.hrow.createOrGetParentRow(modelName,parentBlockPath,createModelInfoArgs);

    vmBlockType=Simulink.variant.manager.VariantManagerBlockType.getVariantManagerBlockType(blockPath);

    parentRow=Simulink.variant.manager.hrow.createVariantManagerHierarchyRow(...
    modelName,parentRow,blockPath,createModelInfoArgs,vmBlockType);
end
