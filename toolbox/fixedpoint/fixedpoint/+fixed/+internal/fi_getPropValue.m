function propValue=fi_getPropValue(this,propName)





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
    case 'Value'



        propValue=mat2str(this);
    case 'DataType'
        propValue=tostring(this.numerictype);
    case 'Dimensions'
        propValue=mat2str(size(this));
    case 'Complexity'
        if isreal(this)
            propValue='real';
        else
            propValue='complex';
        end
    case enum_properties
        propValue=this.(propName);
    case integer_properties
        propValue=int2str(this.(propName));
    case logical_properties
        propValue=int2str(this.(propName));
    case floating_point_properties
        propValue=fixed.internal.compactButAccurateNum2Str(this.(propName));
    otherwise
        propValue='Property value is not found in +embedded/@fi/getPropValue';
    end
end

