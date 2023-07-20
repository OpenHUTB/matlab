



classdef MetricRegistry
    methods(Static=true)
        metricName=cvmetricToStr(cvmetricHandle)
        descrMap=buildMap(descrMap,descrTable,keyIdx)
        table=getMetricDescrTable
        table=getSldvMetricDescrTable
        table=getSimscapeMetricDescrTable
        map=getGenericMetricMap
        table=getGenericMetricDescrTable
        res=getDDEnumVals
        metricName=getDVSupportedMaskTypes(maskName)
        [metricenumVals,metricdescrIds]=registerMetric(cvmetricHandles)
        enumVal=getEnum(metricName)
        [allMetricNames,allTOMetricNames]=getAllMetricNames
        allMetricNames=getAllSettingsMetricNames
        metricNames=getNamesFromAbbrevs(settingStr);
        settingStr=getAbbrevsFromNames(metricNames)
        metricShortDescr=getShortMetricTxt(metricNames,options)
        metricLongDescr=getLongMetricTxt(metricNames,options)
        metricData=getMetricsMetaInfo
        metricNames=getMappedMetricNames(uiMetricName)
        function metricNames=getDefaultMetricNames()
            metricNames={'block'};
        end
        descrTable=setMetricEnums(descrTable)
    end
end
