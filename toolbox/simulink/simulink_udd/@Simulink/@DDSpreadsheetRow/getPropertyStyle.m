function getPropertyStyle(h,propname,style)

    try
        if isequal(propname,'Property')||isequal(propname,'BaseObject')||...
            isequal(propname,'Variant')||isequal(propname,'VariantCondition')||...
            isequal(propname,'DataSource')||isequal(propname,'LastModified')||...
            isequal(propname,'LastModifiedBy')||isequal(propname,'Status')

        else
            if~isempty(h.ddEntry)
                style=getPropertyStyle(h.ddEntry,propname);

                try
                    bUseResolvedView=evalin('base','resolved');
                catch
                    bUseResolvedView=false;
                end
                if bUseResolvedView&&style.Italic
                    style.ForegroundColor=[1,1,1];
                end
            else
                ddConn=Simulink.dd.open(h.DataSource);
                thisEntry=ddConn.getEntryInfo(h.entryID);
                style=getPropertyStyle(thisEntry.Value,propname);
            end
        end
    catch

    end
