function errorMsg=invalidTypeAndFormatError(amiParameter,value,displayedName)





    str=serdes.internal.apps.serdesdesigner.BlockDialog.getStringValue(value);
    type=amiParameter.Type;
    if~type.verifyValueForType(str)
        errorMsg=message('serdes:ibis:MustBeA',displayedName,type.Name);
    elseif strcmpi(amiParameter.Format.Name,"Range")
        errorMsg=message('serdes:serdesdesigner:OutOfRangeEntryMessage',str,displayedName,...
        amiParameter.Format.Min,amiParameter.Format.Max);
    elseif strcmpi(amiParameter.Format.Name,"List")
        errorMsg=message('serdes:ibis:MustBeOneOf',displayedName,mat2str(amiParameter.Format.Values),str);
    else


        errorMsg=message('serdes:ibis:IllegalWithFormat',str,amiParameter.Format.Name);
    end
end