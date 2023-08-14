function t=fi_isReadonlyProperty(this,propName)%#ok<INUSL>




    read_only_properties={
'DataType'
'Dimensions'
'Complexity'
'DataTypeMode'
'Signedness'
'WordLength'
'FractionLength'
'FixedExponent'
'Slope'
'SlopeAdjustmentFactor'
'Bias'
    };

    switch propName
    case read_only_properties
        t=true;
    otherwise
        t=false;
    end

end

