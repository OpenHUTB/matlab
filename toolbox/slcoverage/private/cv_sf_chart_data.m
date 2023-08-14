function[fullNames,widths,numbers,ids]=cv_sf_chart_data(chartId)







    chartDataIds=sf('DataIn',chartId);
    chartDataIds=filter_out_hidden_data(chartDataIds);
    dataCnt=length(chartDataIds);

    fullNames=cell(dataCnt,1);
    [baseNames,parents,numbers]=sf('get',chartDataIds...
    ,'data.name'...
    ,'data.parent'...
    ,'data.number');

    if length(numbers)>1&&all(numbers==0)
        machineId=sf('get',chartId,'chart.machine');
        sf('Private','compute_session_independent_debugger_numbers',machineId);
        numbers=sf('get',chartDataIds,'data.number');
    end


    widths=ones(dataCnt,1);

    for i=1:dataCnt
        if(parents(i)==chartId)
            fullNames{i}=deblank(baseNames(i,baseNames(i,:)~=0));
        else
            fullNames{i}=sf('FullNameOf',chartDataIds(i),'.',chartId);
        end
    end

    ids=chartDataIds;


    function dataIds=filter_out_hidden_data(dataIds)
        for i=1:length(dataIds)
            dataId=dataIds(i);
            parentId=sf('ParentOf',dataId);
            if isempty(sf('Private','filter_out_commented_objects',parentId))
                dataIds(i)=0;
            elseif~isempty(sf('find',parentId,'state.simulink.isSimulinkFcn',1))

                dataIds(i)=0;
            elseif isa(sfroot().idToHandle(parentId),'Stateflow.AtomicSubchart')&&...
                sf('get',dataId,'.scope')==0
                dataIds(i)=0;
            end
        end

        dataIds(dataIds==0)=[];
