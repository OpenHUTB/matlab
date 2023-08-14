function res=getBlockMaskTypeAttributes(~,blkObj,pathItem)










    res.IsSettableInSomeSituations=true;
    switch pathItem

    case '1'

        if strcmp(blkObj.OutputSelection,'Index and fraction as bus')
            res.DataTypeEditField_ParamName='OutputBusDataTypeStr';
        else
            res.DataTypeEditField_ParamName='IndexDataTypeStr';
        end

    case '2'

        res.DataTypeEditField_ParamName='FractionDataTypeStr';

    case 'Breakpoint'

        res.DataTypeEditField_ParamName='BreakpointDataTypeStr';
    end
end


