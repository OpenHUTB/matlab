function mustBeChannels(value)



    try
        mustBeText(value);
    catch ME
        throwAsCaller(ME)
    end
end