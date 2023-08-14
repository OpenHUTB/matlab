




function settingStr=getAbbrevsFromNames(metricNames)

    settingStr=getAbbrev(metricNames,cvi.MetricRegistry.getMetricDescrTable,2);

    function abbrev=getAbbrev(metricNames,dt,propIdx)
        abbrev=[];
        if~iscell(metricNames)
            metricNames={metricNames};
        end
        for idx=1:numel(metricNames)
            mn=metricNames{idx};
            if isfield(dt,mn)
                abbrev=[abbrev,dt.(mn){propIdx}];%#ok<AGROW>
            end
        end
