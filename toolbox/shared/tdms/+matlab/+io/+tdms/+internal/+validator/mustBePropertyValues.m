function mustBePropertyValues(value)



    try
        mustBeVector(value);
    catch ME
        throwAsCaller(ME)
    end
end