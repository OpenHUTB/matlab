function res=getBlockMaskTypeAttributes(~,~,pathItem)










    if isequal(pathItem,'1')||isequal(pathItem,'Output')
        dataName='Output1';
    else
        dataName=pathItem;
    end


    switch dataName
    case 'Output1'
        res.IsSettableInSomeSituations=true;
        res.DataTypeEditField_ParamName='OutDataTypeStr';
        res.LockScaling_ParamName='LockScale';
    case 'Intermediate Results'
        res.IsSettableInSomeSituations=true;
        res.DataTypeEditField_ParamName='IntermediateResultsDataTypeStr';
        res.LockScaling_ParamName='LockScale';
    case 'Table'
        res.IsSettableInSomeSituations=true;
        res.DataTypeEditField_ParamName='TableDataTypeStr';
        res.LockScaling_ParamName='LockScale';
    end
end



