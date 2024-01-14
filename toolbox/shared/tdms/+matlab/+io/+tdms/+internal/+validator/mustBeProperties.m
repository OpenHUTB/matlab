function mustBeProperties(value)
    try
        matlab.io.tdms.internal.validator.mustBeNonEmptyString(value);
    catch ME
        throwAsCaller(ME)
    end
end