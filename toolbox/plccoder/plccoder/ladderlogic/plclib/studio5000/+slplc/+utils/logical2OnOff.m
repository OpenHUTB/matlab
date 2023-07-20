function onoffstr=logical2OnOff(inputArg)





    if islogical(inputArg)
        if inputArg
            onoffstr='on';
        else
            onoffstr='off';
        end
    elseif isnumeric(inputArg)
        onoffstr=slplc.utils.logical2OnOff(logical(inputArg));
    else
        onoffstr=inputArg;
    end

end
