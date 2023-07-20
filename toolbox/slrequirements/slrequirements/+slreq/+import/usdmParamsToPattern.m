function pattern=usdmParamsToPattern(userInput)

    [prefix,remainder]=strtok(userInput);
    if isempty(remainder)
        usdmSep='-';
    else
        usdmSep=remainder(2:end);
    end


    pattern=[prefix,'[\d\',usdmSep,']+'];
end

