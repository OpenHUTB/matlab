function[res]=getBlockMaskTypeAttributes(h,~,pathItem)












    res.IsSettableInSomeSituations=false;

    if regexp(pathItem,'BreakpointsForDimension[1-9]([0-9]|)')

        res.IsSettableInSomeSituations=true;
        res.DataTypeEditField_ParamName=[pathItem,'DataTypeStr'];
        res.LockScaling_ParamName='LockScale';
    else
        outputPathItem=h.getPortMapping([],[],1);
        switch pathItem
        case outputPathItem{1}
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
        case 'Fraction'
            res.IsSettableInSomeSituations=true;
            res.DataTypeEditField_ParamName='FractionDataTypeStr';
            res.LockScaling_ParamName='LockScale';
        end
    end

end


