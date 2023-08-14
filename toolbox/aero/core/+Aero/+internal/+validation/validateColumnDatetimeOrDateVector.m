function validateColumnDatetimeOrDateVector(input,functionName,variableName)





    if isa(input,"datetime")
        validateattributes(input,{'datetime'},{'column'},functionName,variableName)
    else
        validateattributes(input,{'numeric'},{'ncols',6,'real','finite','nonnan'},functionName,variableName)
    end
end

