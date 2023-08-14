function allowed_values=fi_getPropAllowedValues(~,propName)








    switch propName
    case 'DataTypeMode'
        allowed_values={'Boolean'
'Single'
'Double'
'Fixed-point: binary point scaling'
'Fixed-point: slope and bias scaling'
'Scaled double: binary point scaling'
        'Scaled double: slope and bias scaling'};
    case 'Signedness'
        allowed_values={'Signed'
        'Unsigned'};
    case{'DDGRoundingMethod'}
        allowed_values={'Ceiling'
'Convergent'
'Zero'
'Floor'
'Nearest'
        'Round'};
    case 'DDGOverflowAction'
        allowed_values={'Saturate'
        'Wrap'};
    case{'DDGProductMode','DDGSumMode'}
        allowed_values={'FullPrecision'
'KeepLSB'
'KeepMSB'
        'SpecifyPrecision'};
    otherwise
        allowed_values={};
    end
end
