function mustBeTdmsFile(value)
    try
        value=convertCharsToStrings(value);
        mustBeScalarOrEmpty(value);
        mustBeA(value,"string");
    catch ME
        throwAsCaller(ME)
    end
end

