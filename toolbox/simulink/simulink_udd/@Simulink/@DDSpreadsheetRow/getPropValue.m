function propValue=getPropValue(thisObj,propName)


    try
        if isequal(propName,'Property')
            propValue=thisObj.propertyName;
        elseif isequal(propName,'Variant')
            propValue=getPropValue(thisObj.ddEntry,thisObj.propertyName);
        elseif isequal(propName,'BaseObject')
            ddConn=Simulink.dd.open(thisObj.DataSource);
            thisEntry=ddConn.getEntryInfo(thisObj.entryID);
            baseEntryID=thisEntry.Value.m_baseEntryID;
            baseEntry=ddConn.getEntryInfo(baseEntryID);
            propValue=getPropValue(baseEntry.Value,thisObj.propertyName);
        elseif isequal(propName,'VariantCondition')
            propValue=thisObj.variantCondition;
        elseif isequal(propName,'DataSource')
            propValue=thisObj.DataSource;
        elseif isequal(propName,'LastModified')
            propValue=thisObj.LastModified;
        elseif isequal(propName,'LastModifiedBy')
            propValue=thisObj.LastModifiedBy;
        elseif isequal(propName,'Status')
            propValue=thisObj.Status;
        else
            if~isempty(thisObj.ddEntry)
                propValue=getPropValue(thisObj.ddEntry,propName);
            else
                ddConn=Simulink.dd.open(thisObj.DataSource);
                thisEntry=ddConn.getEntryInfo(thisObj.entryID);
                propValue=getPropValue(thisEntry.Value,propName);
            end
        end
    catch
        propValue='';
    end
