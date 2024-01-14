function mustBeAChannelGroup(value)
    try
        mustBeTextScalar(value);
    catch ME
        throwAsCaller(ME)
    end
end