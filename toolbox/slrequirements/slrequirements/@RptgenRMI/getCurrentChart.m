function chartPath=getCurrentChart()

    sfData=rptgen_sf.appdata_sf;
    chartPath=get(sfData.CurrentObject,'Path');
end

