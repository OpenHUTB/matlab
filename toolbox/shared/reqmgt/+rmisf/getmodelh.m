function result=getmodelh(handle)




    chart_isa=sf('get','default','chart.isa');
    handle_isa=sf('get',handle,'.isa');
    if chart_isa==handle_isa
        chart_handle=handle;
    else
        objIsa=sf('get',handle,'.isa');
        sfisa=rmisf.sfisa();
        if objIsa==sfisa.data
            m=sf('get',handle,'.machine');
            charts=sf('get',m,'.charts');
            chart_handle=charts(1);
        else
            chart_handle=sf('get',handle,'.chart');
        end
    end
    result=get_param(bdroot(sf('Private','chart2block',chart_handle)),'handle');
end