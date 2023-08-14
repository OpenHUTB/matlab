function[metricNames,toMetricNames]=get_common_metric_names(allTests)




    if~iscell(allTests)
        allTests={allTests};
    end
    [metricNames,toMetricNames]=getUsedMetricNames(allTests{1});
    for i=2:numel(allTests)
        [tmpMetricNames,tmpToMetricNames]=getUsedMetricNames(allTests{i});
        metricNames=unique([metricNames,tmpMetricNames],'stable');
        toMetricNames=unique([toMetricNames,tmpToMetricNames],'stable');
    end
end

function[metricNames,toMetricNames]=getUsedMetricNames(cvd)
    [metricNames,toMetricNames]=getEnabledMetricNames(cvd);
    metricNames=setdiff(metricNames,cvi.ReportUtils.check_no_data(cvd,metricNames));
    toMetricNames=setdiff(toMetricNames,cvi.ReportUtils.check_no_data(cvd,toMetricNames));

end


