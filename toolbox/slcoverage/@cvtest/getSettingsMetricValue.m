function value=getSettingsMetricValue(cvtest,metricName)
    mappedMetricNames=cvi.MetricRegistry.getMappedMetricNames(metricName);
    if~isempty(mappedMetricNames)
        value=getTOMetricValue(cvtest,mappedMetricNames);
    else
        value=getMetricValue(cvtest,metricName);
    end
end
