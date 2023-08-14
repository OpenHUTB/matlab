function distance=getLowerBoundToNegativeEpsOfZeroDistance(datatype)

























    [isFloat,datatype]=fixed.internal.type.isAnyFloat(datatype);
    assert(isFloat,'datatype must be a floating point type');
    if isdouble(datatype)

        distance=uint64(9218868437227405311);
    elseif issingle(datatype)

        distance=uint32(2139095039);
    elseif ishalf(datatype)

        distance=uint16(31743);
    end
end