function propValue=fimath_getPropValue(this,propName)





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
        propValue=this.(propName);
    case integer_properties
        propValue=int2str(this.(propName));
    case logical_properties
        propValue=int2str(this.(propName));
    case floating_point_properties
        propValue=fixed.internal.compactButAccurateNum2Str(this.(propName));
    otherwise
        propValue='Property value is not found in +embedded/@fimath/getPropValue';
    end
end

