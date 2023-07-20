function mode=checkSimulationMode(mode,fcnName,argPos)






    try
        mode=convertStringsToChars(mode);
        if ischar(mode)
            validateattributes(mode,{'char'},{'nonempty','vector','nrows',1},fcnName,'',argPos);
            mode=SlCov.CovMode.fromString(mode,1);
        elseif~isempty(mode)
            mode=SlCov.CovMode(mode);
        end



        mode=SlCov.CovMode.fixTopMode(mode);
    catch Me
        throwAsCaller(Me);
    end


