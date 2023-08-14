function exists=existsVarStructFields(modelName,varName,baseStructName)










    allElements=strsplit(varName,'.');
    lastField=allElements{end};
    fieldSplit=strsplit(lastField,{'(','{'});
    fieldToCheck=fieldSplit{1};
    exists=Simulink.variant.utils.isFieldPresentInStruct(modelName,baseStructName,fieldToCheck);
end