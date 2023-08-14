function expandModelHierarchyRootRow(modelHandle)






    vmStudioHandle=slvariants.internal.manager.core.getStudio(modelHandle);
    modelHierSSComp=vmStudioHandle.getComponent('GLUE2:SpreadSheet',message('Simulink:VariantManagerUI:HierarchyTitleVariant').getString());
    modelHierSSSrc=modelHierSSComp.getSource;
    rootRow=modelHierSSSrc.RootRow;
    rootRow.expandRow(false);
end