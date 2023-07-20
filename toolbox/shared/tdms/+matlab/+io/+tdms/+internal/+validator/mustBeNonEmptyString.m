function mustBeNonEmptyString(text)





    if matlab.io.tdms.internal.utility.isEmptyString(text)
        throwAsCaller(MException(message("MATLAB:validators:mustBeNonempty")));
    end
end