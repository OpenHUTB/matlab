




function map=getGenericMetricMap

    persistent pGenericMetricMap;


    if isempty(pGenericMetricMap)
        pGenericMetricMap=cvi.MetricRegistry.buildMap(pGenericMetricMap,cvi.MetricRegistry.getGenericMetricDescrTable,2);
        pGenericMetricMap=cvi.MetricRegistry.buildMap(pGenericMetricMap,cvi.MetricRegistry.getSldvMetricDescrTable,2);
        if strcmpi(cv('Feature','simscapeCoverage'),'on')
            pGenericMetricMap=cvi.MetricRegistry.buildMap(pGenericMetricMap,cvi.MetricRegistry.getSimscapeMetricDescrTable,2);
        end
    end

    map=pGenericMetricMap;

