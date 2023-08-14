function row=createRow(parentRow,rowArgsStruct,blockPathInModel)




    HrowFcn=@Simulink.internal.vmgr.HierarchyRow;
    row=HrowFcn(parentRow,rowArgsStruct.RootModelOrBlockName,rowArgsStruct.VMBlockType,...
    rowArgsStruct.VariantChoiceInformation,blockPathInModel);
end