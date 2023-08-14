




function allMetricNames=getAllSettingsMetricNames
    allMetricNames=fieldnames(cvi.MetricRegistry.getMetricDescrTable)';

    for idx=1:numel(allMetricNames)
        if strcmpi(allMetricNames{idx},'block')
            allMetricNames(idx)=[];
            break;
        end
    end
