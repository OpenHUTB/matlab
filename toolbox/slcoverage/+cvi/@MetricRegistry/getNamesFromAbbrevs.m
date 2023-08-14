




function metricNames=getNamesFromAbbrevs(abbrevs)

    dt=cvi.MetricRegistry.getMetricDescrTable;
    fn=fieldnames(dt);
    metricNames=[];
    for idx=1:numel(fn)
        cfn=fn{idx};
        if strfind(abbrevs,dt.(cfn){2})
            metricNames{end+1}=cfn;%#ok<AGROW>
        end
    end

