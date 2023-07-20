function castFunction=getCastToIntegerFunctionForFloatingPoint(datatype)

























    [isFloat,datatype]=fixed.internal.type.isAnyFloat(datatype);
    assert(isFloat,'datatype must be a floating point type');
    if isdouble(datatype)
        castFunction=@(x)typecast(x,'uint64');
    elseif issingle(datatype)
        castFunction=@(x)typecast(x,'uint32');
    elseif ishalf(datatype)
        castFunction=@(x)storedInteger(x);
    end
end