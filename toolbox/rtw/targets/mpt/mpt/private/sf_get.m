function value=sf_get(name,attribute)




























    value=[];
    try
        attrib_lower=lower(attribute);
        switch(attrib_lower)

        case 'charthandle'
            value=sf('Private','block2chart',name);





















        case 'charthghandle'
            ChartHandle=sf_get(name,'ChartHandle');
            value=sf('get',ChartHandle,'.hg.figure');

        case 'chartlist'
            machineId=sf_get(name,'MachineId');
            chartHandles=sf('get',machineId,'.charts');
            if isempty(chartHandles)==0
                for i=1:length(chartHandles)
                    value(i).name=sf('get',chartHandles(i),'.name');
                    value(i).handle=chartHandles(i);
                end
            end
        case 'chartlistlinked'
            machineId=sf_get(name,'MachineId');
            chartHandles=sf('get',machineId,'.linkCharts');
            if isempty(chartHandles)==0
                for i=1:length(chartHandles)
                    value(i).name=sf('get',chartHandles(i),'.name');
                    value(i).handle=chartHandles(i);
                end
            end
        case 'machineid'
            [name,r]=strtok(name,'/');
            machineId=sf('get','all','machine.id');
            if isempty(machineId)==0
                for i=1:length(machineId)
                    mName=sf('get',machineId(i),'.name');
                    if(strcmp(name,mName)==1)
                        value=machineId(i);
                        break
                    end
                end
            end
        case 'statelist'



            machineId=sf_get(name,'machineId');
            chartHandles=sf('get',machineId,'.charts');
            k=1;

            for i=1:length(chartHandles)
                listh=sf('get',chartHandles(i),'.states');
                for j=1:length(listh)
                    value(k).name=sf('get',listh(j),'.name');
                    value(k).handle=listh(j);
                    k=k+1;
                end
            end
        case 'version'
            machineId=sf('find','all','machine.simulinkModel',0);
            value=sf('get',machineId,'.sfVersion');
        otherwise,
        end
    catch
        value=[];
    end

    function newName=remove_top(name)
        [t,r]=strtok(name,'/');
        newName=r(2:end);
