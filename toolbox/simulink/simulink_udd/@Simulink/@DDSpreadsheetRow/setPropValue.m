function setPropValue(thisObj,propName,value)

    propNameToAnnounce=propName;
    try
        if isequal(propName,'Variant')
            setPropValue(thisObj.ddEntry,thisObj.propertyName,value);
            propNameToAnnounce=thisObj.propertyName;
        elseif isequal(propName,'VariantCondition')
            thisObj.variantCondition=value;
        elseif~isempty(thisObj.ddEntry)
            setPropValue(thisObj.ddEntry,propName,value);
        else
            ddConn=Simulink.dd.open(thisObj.DataSource);
            thisEntry=ddConn.getEntryInfo(thisObj.entryID);
            setPropValue(thisEntry.Value,propName,value);
        end
        thisObj.isDirty=true;
        if~isempty(thisObj.entryDDG)
            try
                childRowChanged(thisObj.entryDDG,thisObj.ddEntry,propNameToAnnounce);
            catch E
            end
        end
    catch

    end
