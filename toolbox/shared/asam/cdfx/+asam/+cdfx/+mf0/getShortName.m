function shortname=getShortName(instanceElement)




    if strcmp(string(instanceElement.SHORT_NAME.elementValue),"")
        error(message('asam_cdfx:CDFX:MissingExpectedElement'));
    end
    shortname=string(instanceElement.SHORT_NAME.elementValue);
end

