
function[enabledMetricNames,enabledTOMetricNames,enabledMetricsStruct]=...
    getMetricsForSummary(allTests,recordedMetricNames,recordedTOMetricNames,options)





    metricDescrTable=cvi.MetricRegistry.getMetricDescrTable;
    [allMetricNames,allTOMetricNames]=cvi.MetricRegistry.getAllMetricNames;

    enabledMetrics_allTests=cellfun(@(c)c.testSettings,allTests);
    enabledMetrics_allTests(1).block=~options.filtExecMetric;
    if isfield(enabledMetrics_allTests,'sigsize')
        enabledMetrics_allTests=rmfield(enabledMetrics_allTests,'sigsize');
    end
    if isfield(enabledMetrics_allTests,'sigrange')
        enabledMetrics_allTests=rmfield(enabledMetrics_allTests,'sigrange');
    end
    enabledMetricsStruct=enabledMetrics_allTests(1);

    enabledMetricIdxs=zeros(size(allMetricNames),'logical');
    enabledTOMetricIdxs=zeros(size(allTOMetricNames),'logical');
    metricFields=fields(metricDescrTable);
    for i=1:length(metricFields)
        metricF=metricFields{i};
        isEnabled=false;
        if isfield(enabledMetrics_allTests,metricF)
            isEnabled=any([enabledMetrics_allTests.(metricF)]);
            enabledMetricsStruct.(metricF)=isEnabled;
        end

        matchedMetrics=metricDescrTable.(metricF){9};
        if isempty(matchedMetrics)
            matchedMetrics={metricF};
        end
        enabledMetricIdxs(ismember(allMetricNames,matchedMetrics))=isEnabled;
        enabledTOMetricIdxs(ismember(allTOMetricNames,matchedMetrics))=isEnabled;
    end

    enabledMetricNames=allMetricNames(enabledMetricIdxs);
    enabledTOMetricNames=allTOMetricNames(enabledTOMetricIdxs);


    allRecordedMetricNames=[recordedMetricNames,recordedTOMetricNames];
    allEnabledMetricNames=[enabledMetricNames,enabledTOMetricNames];
    if~all(ismember(allRecordedMetricNames,allEnabledMetricNames))




        enabledMetricNames=union(recordedMetricNames,enabledMetricNames,'legacy');
        enabledTOMetricNames=union(recordedTOMetricNames,enabledTOMetricNames,'legacy');

        for i=1:length(metricFields)
            metricF=metricFields{i};
            matchedMetrics=metricDescrTable.(metricF){9};
            if isempty(matchedMetrics)
                matchedMetrics={metricF};
            end

            if any(ismember(matchedMetrics,allRecordedMetricNames))
                enabledMetricsStruct.(metricF)=true;
            end
        end
    end


