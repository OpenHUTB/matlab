function readonly=isReadonlyProperty(h,propname)

    readonly=true;
    try
        if isequal(propname,'Property')||isequal(propname,'BaseObject')
            readonly=true;
        elseif isequal(propname,'Variant')||isequal(propname,'DataSource')


            readonly=true;
        elseif isequal(propname,'VariantCondition')
            readonly=false;
        else
            readonly=false;
            if~isempty(h.ddEntry)
                readonly=isReadonlyProperty(h.ddEntry,propname);
            else
                ddConn=Simulink.dd.open(h.DataSource);
                thisEntry=ddConn.getEntryInfo(h.entryID);
                readonly=isReadonlyProperty(thisEntry.Value,propname);
            end
        end
    catch
    end
