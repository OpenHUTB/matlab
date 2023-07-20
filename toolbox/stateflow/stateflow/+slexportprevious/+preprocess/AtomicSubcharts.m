function AtomicSubcharts(obj)






    machineH=getStateflowMachine(obj);
    if isempty(machineH)
        return;
    end

    if isR2010aOrEarlier(obj.ver)
        charts=machineH.find('-isa','Stateflow.Chart');
        for i=1:length(charts)
            ch=charts(i);
            if~ishandle(ch)


                continue
            end
            subcharts=ch.find('-isa','Stateflow.AtomicSubchart');

            for j=1:length(subcharts)
                subchart=subcharts(j);

                relPath=sf('FullName',subchart.Id,subchart.Chart.id,'.');
                chartRelPath=sf('FullName',subchart.Chart.Id,subchart.Machine.Id,'/');
                obj.reportWarning('Stateflow:subchart:SaveInPrevVersion',relPath,chartRelPath);

                delete(subchart);
            end
        end
    elseif isR2014bOrEarlier(obj.ver)
        atomicSubchartStates=machineH.find('-isa','Stateflow.AtomicSubchart');
        chartsToToast=containers.Map('KeyType','double','ValueType','double');
        for subchart=atomicSubchartStates(:)'
            if Stateflow.SLINSF.SubchartMan.removeNontrivialMappings(subchart)
                parentChartId=subchart.chart.id;
                chartsToToast(parentChartId)=1;
                relPath=sf('FullName',subchart.Id,parentChartId,'.');
                chartRelPath=sf('FullName',parentChartId,subchart.Machine.Id,'/');
                obj.reportWarning('Stateflow:subchart:SaveInPrevVersionWithNonTrivialMapping',relPath,chartRelPath)
            end
        end
        chartsToToastIds=cell2mat(chartsToToast.keys);
        for iter=1:length(chartsToToastIds)
            sf('Toast',chartsToToastIds(iter));
        end
    end

end
