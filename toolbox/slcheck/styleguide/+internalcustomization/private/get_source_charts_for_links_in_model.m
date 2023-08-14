function sourceChartObjects=get_source_charts_for_links_in_model(modelName,ref_list)



    machineId=sf('find','all','machine.name',modelName);
    linkCharts=sf('get',machineId,'machine.sfLinks');
    sourceCharts=[];
    for i=1:length(linkCharts)
        sourceCharts(i)=sfprivate('block2chart',linkCharts(i));
    end

    sourceCharts=unique(sourceCharts);

    sfRoot=sfroot;
    sourceChartObjects=[];
    for i=1:length(sourceCharts)
        chartObj=sfRoot.idToHandle(sourceCharts(i));
        if ismember(chartObj.Path,ref_list)
            sourceChartObjects{end+1}=sfRoot.idToHandle(sourceCharts(i));
        end
    end
