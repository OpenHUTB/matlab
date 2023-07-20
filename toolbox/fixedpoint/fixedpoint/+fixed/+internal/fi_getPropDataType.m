function dataType=fi_getPropDataType(~,propName)




    string_properties={
'DataType'
'Dimensions'
'Complexity'
'Value'
    };
    enum_properties={
'DataTypeMode'
'Signedness'
'DDGRoundingMethod'
'DDGOverflowAction'
'DDGProductMode'
'DDGSumMode'
    };

    integer_properties={
'WordLength'
'FractionLength'
'FixedExponent'
'DDGProductWordLength'
'DDGProductFractionLength'
'DDGProductFixedExponent'
'DDGSumWordLength'
'DDGSumFractionLength'
'DDGSumFixedExponent'
    };

    logical_properties={
'fimathislocal'
'DDGCastBeforeSum'
    };

    floating_point_properties={
'Slope'
'SlopeAdjustmentFactor'
'Bias'
'DDGProductBias'
'DDGProductSlope'
'DDGSumSlope'
'DDGSumBias'
    };

    switch propName
    case string_properties
        dataType='string';
    case enum_properties
        dataType='enum';
    case integer_properties
        dataType='int';
    case logical_properties
        dataType='bool';
    case floating_point_properties
        dataType='double';
    otherwise
        dataType='string';
    end

end

