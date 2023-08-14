




function[allMetricNames,allTOMetricNames]=getAllMetricNames
    persistent persistantAllMetricNames
    persistent persistantallTOMetricNames

    if isempty(persistantAllMetricNames)
        persistantAllMetricNames=[];
        persistantallTOMetricNames=[];
        allUiMetricNames=fieldnames(cvi.MetricRegistry.getMetricDescrTable)';
        for idx=1:numel(allUiMetricNames)
            cmn=allUiMetricNames{idx};
            mappedMetricNames=cvi.MetricRegistry.getMappedMetricNames(cmn);
            if isempty(mappedMetricNames)
                persistantAllMetricNames{end+1}=cmn;
            else
                persistantallTOMetricNames=[persistantallTOMetricNames,mappedMetricNames];
            end
        end
    end
    allMetricNames=persistantAllMetricNames;
    allTOMetricNames=persistantallTOMetricNames;
