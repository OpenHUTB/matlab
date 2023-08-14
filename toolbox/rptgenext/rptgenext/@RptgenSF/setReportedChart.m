function setReportedChart(obj)






    if isnumeric(obj)
        obj=rptgen_sf.id2handle(obj);
    end

    if isa(obj,'Stateflow.Chart')
        set(rptgen_sf.appdata_sf,'CurrentChart',obj);
    else
        error(message('RptgenSL:rptgen_sf:expectedChart',class(obj)));
    end
