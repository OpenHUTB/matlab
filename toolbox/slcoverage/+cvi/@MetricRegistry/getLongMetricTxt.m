function metricLongDescr=getLongMetricTxt(metricNames,options)

    metricLongDescr=[];
    if~iscell(metricNames)
        metricNames={metricNames};

    end
    dt1=cvi.MetricRegistry.getGenericMetricMap;
    dt2=cvi.MetricRegistry.getMetricDescrTable;
    for idx=1:numel(metricNames)
        mn=metricNames{idx};
        if isfield(dt1,mn)
            longName=dt1.(mn){5};
            if iscell(longName)&&~isempty(options)
                longName=longName{options.alternativeMetricNameIdx};
            end
        else
            if isfield(dt2,mn)
                longName=dt2.(mn){5};
            end

        end
        metricLongDescr=[metricLongDescr,{longName}];%#ok<AGROW>
    end
    if numel(metricLongDescr)==1
        metricLongDescr=metricLongDescr{1};
    end