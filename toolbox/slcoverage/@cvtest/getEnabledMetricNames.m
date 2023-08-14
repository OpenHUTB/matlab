function[enabled,enabledTO]=getEnabledMetricNames(cvtest)




    enabled={};
    enabledTO={};
    [metricNames,toMetricNames]=cvi.MetricRegistry.getAllMetricNames;

    for metric=metricNames(:)'
        if(getMetricValue(cvtest,metric{1}))
            enabled{end+1}=metric{1};
        end
    end

    for metric=toMetricNames(:)'
        if(getTOMetricValue(cvtest,metric{1}))
            enabledTO{end+1}=metric{1};
        end
    end

