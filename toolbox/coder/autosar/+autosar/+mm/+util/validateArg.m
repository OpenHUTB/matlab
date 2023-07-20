function validateArg(m3iArg,expectedClass)





    narginchk(2,2);

    assert(ischar(expectedClass)||isStringScalar(expectedClass),...
    'Expected "char" or "string" type for input argument, got %s!',...
    expectedClass);

    assert(isa(m3iArg,expectedClass),...
    'Expected "%s" type for input argument, got %s!',...
    expectedClass,class(m3iArg));
end

