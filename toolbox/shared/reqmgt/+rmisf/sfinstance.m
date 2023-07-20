function instanceHandle=sfinstance(sfObj)




    chartId=sfGetChartId(sfObj);

    activeInstance=sf('get',chartId,'chart.activeInstance');
    if(activeInstance==0.0)
        instanceHandle=sf('Private','chart2block',chartId);
    else
        instanceHandle=activeInstance;
    end


    function chart_handle=sfGetChartId(sfObj)

        chart_isa=sf('get','default','chart.isa');
        handle_isa=sf('get',sfObj,'.isa');
        if(chart_isa==handle_isa)
            chart_handle=sfObj;
        else
            chart_handle=sf('get',sfObj,'.chart');
        end

