

function[res,summ,resMetricNames]=isShortSummary(this,dataEntry,options)




    res=true;
    summ=[];
    metricNames=[this.metricNames,this.toMetricNames];

    fullCovMetricNames={};
    resMetricNames={};

    for i=1:numel(metricNames)
        thisMetric=metricNames{i};
        if isfield(dataEntry,thisMetric)&&~isempty(dataEntry.(thisMetric))&&...
            isfield(dataEntry.(thisMetric),'flags')&&...
            ~isempty(dataEntry.(thisMetric).flags.fullCoverage)
            if~all(dataEntry.(thisMetric).flags.fullCoverage)
                res=false;
                break;
            end
            fullCovMetricNames{end+1}=thisMetric;%#ok<AGROW>
        end
    end
    if res
        res=true;
        summ=[];
        for idx=1:numel(fullCovMetricNames)
            metricSummAbbrev=cvi.MetricRegistry.getShortMetricTxt(fullCovMetricNames{idx},options);
            summ=[summ,metricSummAbbrev];%#ok<AGROW>
            resMetricNames=[resMetricNames,fullCovMetricNames(idx)];%#ok<AGROW>
            if numel(fullCovMetricNames)>1&&idx<numel(fullCovMetricNames)
                summ=[summ,', '];%#ok<AGROW>
            end
        end
    end



