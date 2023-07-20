




function metricNames=getMappedMetricNames(uiMetricName)
    metricNames={};
    mt=cvi.MetricRegistry.getMetricDescrTable;
    if isfield(mt,uiMetricName)
        metricNames=mt.(uiMetricName){9};
    end
