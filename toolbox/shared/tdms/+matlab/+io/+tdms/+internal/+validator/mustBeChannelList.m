function mustBeChannelList(value)



    try
        mustBeA(value,'table');
    catch ME
        throwAsCaller(ME);
    end
end