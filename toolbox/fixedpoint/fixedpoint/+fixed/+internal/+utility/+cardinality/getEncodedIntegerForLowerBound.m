function encodedInteger=getEncodedIntegerForLowerBound(datatype)


























    datatype=fixed.internal.type.extractNumericType(datatype);
    if isdouble(datatype)

        encodedInteger=uint64(18442240474082181119);
    elseif issingle(datatype)

        encodedInteger=uint32(4286578687);
    elseif ishalf(datatype)

        encodedInteger=uint16(64511);
    elseif isboolean(datatype)
        encodedInteger=fixed.internal.math.castLogicalToUfix1(false);
    else

        unscaledType=fixed.internal.type.stripScaling(datatype);
        encodedInteger=lowerbound(unscaledType);
    end
end