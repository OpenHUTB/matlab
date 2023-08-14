function allowed_values=fimath_getPropAllowedValues(~,propName)








    switch propName
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
