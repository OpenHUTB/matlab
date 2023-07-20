




function enumVals=getEnum(metricNames)
    enumVals=[];
    if~iscell(metricNames)
        metricNames={metricNames};
    end
    dt=cvi.MetricRegistry.getMetricDescrTable;
    for idx=1:numel(metricNames)
        mn=metricNames{idx};
        if isfield(dt,mn)
            enumVals=[enumVals,dt.(mn){4}];%#ok<AGROW>
        else
            mmap=cvi.MetricRegistry.getGenericMetricMap;
            if isfield(mmap,mn)
                enumVals=[enumVals,mmap.(mn){4}];%#ok<AGROW>
            end
        end
    end

