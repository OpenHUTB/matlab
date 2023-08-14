function displayText=getParamValueText(parameterValue,blockType)












    if~iscell(parameterValue)
        displayText=parameterValue;
    else
        displayText=strjoin(parameterValue,', ');
    end


    if~strcmp(blockType,'SimscapeBlock')
        return;
    end

    try
        enumKey=eval(parameterValue);

        if~isenum(enumKey)||~ismethod(enumKey,'displayText')
            return;
        end
    catch
        return;
    end

    m=enumKey.displayText();
    enumKey=char(enumKey);


    if isKey(m,enumKey)
        displayText=m(enumKey);


        try
            msg=message(displayText);
            displayText=getString(msg);
        catch
        end
    end
end