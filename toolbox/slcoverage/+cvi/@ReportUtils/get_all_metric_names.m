function[metricNames,toMetricNames]=get_all_metric_names(allTests)





    metricNames={};
    toMetricNames=[];
    if~iscell(allTests)
        allTests={allTests};
    end
    for i=1:length(allTests)
        [thisMetrics,thisToMetricName]=getEnabledMetricNames(allTests{i});
        thisMetrics=setdiff(thisMetrics,cvi.ReportUtils.check_no_data(allTests{i},thisMetrics),'legacy');
        thisToMetricName=setdiff(thisToMetricName,cvi.ReportUtils.check_no_data(allTests{i},thisToMetricName),'legacy');
        metricNames=union(metricNames,thisMetrics,'legacy');
        toMetricNames=union(toMetricNames,thisToMetricName,'legacy');
    end


