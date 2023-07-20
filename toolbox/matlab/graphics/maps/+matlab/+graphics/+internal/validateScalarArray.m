function validateScalarArray(A,classes,funcname,varname)






    try
        if length(A)<=1
            validateattributes(A,classes,{'scalar'},funcname,varname)
        else






            validateattributes(A(ones(size(A))),classes,{'scalar'},funcname,varname)
        end
    catch e
        throwAsCaller(e)
    end
end
