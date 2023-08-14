function newFilter=deriveHarnessFilter(this,harnessSubsys)




    values=this.filterState.values;
    harnessSubsysName=getfullname(harnessSubsys);

    newFilter=SlCov.FilterEditor.createFilterEditor(bdroot(harnessSubsys),[]);
    for idx=1:numel(values)
        prop=values{idx};
        if this.hasSSID(prop)
            ssid=this.getPropSSID(prop);
            newssid=mapSSID(this.modelName,harnessSubsysName,ssid);
            if isempty(newssid)

                continue;
            end
            newProps=this.getProperties(newssid);
            for j=1:numel(newProps)
                if strcmpi(newProps(j).id,prop.id)
                    newProps(j).Rationale=prop.Rationale;
                    newFilter.addFilterPropToState(newProps(j));
                    break;
                end
            end
        else
            newFilter.addFilterPropToState(prop);
        end
    end






    function newSSID=mapSSID(modelName,harnessSubsysName,ssid)

        modelObject=SlCov.FilterEditor.getObject(ssid);
        if isempty(modelObject)
            newSSID=ssid;
            return;
        end

        if strfind(class(modelObject),'Stateflow.')
            chartObj=modelObject.Chart;
            newChartSSID=mapSSID(modelName,harnessSubsysName,Simulink.ID.getSID(chartObj));
            newChartModelObject=SlCov.FilterEditor.getObject(newChartSSID);
            chart=newChartModelObject.find('-isa','Stateflow.Chart');
            newModelObject=chart.find('SSIdNumber',modelObject.SSIdNumber);
            newSSID=Simulink.ID.getSID(newModelObject);
        else
            fn=modelObject.getFullName;
            if~isempty(strfind(fn,modelName))
                fn=[harnessSubsysName,fn(numel(modelName)+1:end)];
            end
            try
                newSSID=Simulink.ID.getSID(fn);
            catch Mex %#ok<NASGU>

                newSSID='';
            end
        end


