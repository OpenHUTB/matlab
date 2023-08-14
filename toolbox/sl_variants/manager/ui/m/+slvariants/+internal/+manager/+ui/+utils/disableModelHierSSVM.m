function disableModelHierSSVM(modelHandle)




    vmStudioHandle=slvariants.internal.manager.core.getStudio(modelHandle);
    modelHierarchySS=vmStudioHandle.getComponent('GLUE2:SpreadSheet',...
    message('Simulink:VariantManagerUI:HierarchyTitleVariant').getString());
    modelHierarchySS.disable;
end
