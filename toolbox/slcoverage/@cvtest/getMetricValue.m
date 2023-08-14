function value=getMetricValue(cvtest,metricName)

    enumVal=cvi.MetricRegistry.getEnum(metricName);
    value=[];
    if~isempty(enumVal)
        value=cv('get',cvtest.id,['testdata.settings.',metricName]);
    end
