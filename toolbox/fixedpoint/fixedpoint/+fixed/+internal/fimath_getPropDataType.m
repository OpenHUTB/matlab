function dataType=fimath_getPropDataType(~,propName)










    enum_properties={
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

