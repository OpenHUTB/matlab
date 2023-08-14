




function map=getSldvMetricMap

    persistent pSldvMap

    assert(false);
    if isempty(pSldvMap)
        pSldvMap=cvi.MetricRegistry.buildMap(cvi.MetricRegistry.getSldvMetricDescrTable,2);
    end

    map=pSldvMap;

