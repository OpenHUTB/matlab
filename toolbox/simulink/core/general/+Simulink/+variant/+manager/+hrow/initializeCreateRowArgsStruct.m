function rowArgsStruct=initializeCreateRowArgsStruct()




    rowArgsStructFieldNames={'RootModelOrBlockName','VMBlockType',...
    'VarControl','VarCondition',...
    'ValidationResultType',...
    'VariantChoiceInformation'};
    rowArgsStructFieldValues=cell(1,length(rowArgsStructFieldNames));
    rowArgsStruct=cell2struct(rowArgsStructFieldValues,rowArgsStructFieldNames,2);
end
