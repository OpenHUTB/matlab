function setReportedState(obj)






    if isnumeric(obj)
        obj=rptgen_sf.id2handle(obj);
    end

    if isa(obj,'Stateflow.State')
        set(rptgen_sf.appdata_sf,'CurrentState',obj);
    else
        error(message('RptgenSL:rptgen_sf:expectedState',class(obj)));
    end
