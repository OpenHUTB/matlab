

function chartHandle=getSFChartHandleFromSFID(id)
    chartHandle=-1;
    if id>0
        chartId=sfprivate('getChartOf',id);
        if chartId>0
            chartHandle=sfprivate('chart2block',chartId);
        end
    end
end