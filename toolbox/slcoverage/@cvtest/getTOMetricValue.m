function value=getTOMetricValue(cvtest,metricName)

    enumValue=cvi.MetricRegistry.getEnum(metricName);
    metricDataId=cv('get',cvtest.id,'testdata.testobjectives');
    metricenumValues=cv('get',metricDataId,'.metricenumValue');

    value=any(ismember(enumValue,metricenumValues));
