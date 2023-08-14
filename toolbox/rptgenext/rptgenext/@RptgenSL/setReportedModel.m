function setReportedModel(obj)









    if isnumeric(obj)

        obj=getfullname(obj);
    elseif ishandle(obj)
        obj=getfullname(obj.Handle);
    end

    set(rptgen_sl.appdata_sl,'CurrentModel',obj);