function validateScalarDatetimeOrDateVector(input,functionName,variableName)





    if isa(input,"datetime")
        validateattributes(input,{'datetime'},{'scalar'},functionName,variableName)
    else
        validateattributes(input,{'numeric'},{'numel',6,'real','finite','nonnan'},functionName,variableName)
    end
end

