function isEnabled=assessModelRefEnabled(modelName,modelRefEnable,modelRefExcludeList)






    if strcmpi(modelRefEnable,'all')||strcmpi(modelRefEnable,'on')
        isEnabled=true;
    elseif strcmpi(modelRefEnable,'filtered')
        if any(strcmp(modelName,modelRefExcludeList))
            isEnabled=false;
        else
            isEnabled=true;
        end
    else
        isEnabled=false;
    end
