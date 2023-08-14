function setReportedObject(obj)






    if isnumeric(obj)
        obj=rptgen_sf.id2handle(obj);
    end

    if isa(obj,'Stateflow.Object')
        set(rptgen_sf.appdata_sf,'CurrentObject',obj);
    else
        error(message('RptgenSL:rptgen_sf:expectedObject',class(obj)));
    end
