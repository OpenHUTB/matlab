function applyReqMask(this,isMasked)








    if isempty(this.aggregatedTestInfo)
        return;
    end

    if(~this.traceOn)||isempty(this.trace)
        return;
    end

    [metricNames,toMetricNames]=getEnabledMetricNames(this);
    deleteIdx=contains(metricNames,{'sigrange','sigsize'});
    metricNames(deleteIdx==1)=[];
    allMetricNames=[metricNames,toMetricNames];
    isTOmetric=[zeros(1,numel(metricNames)),ones(1,numel(toMetricNames))];

    traceMask=this.getTraceMask();
    for metricIdx=1:length(allMetricNames)
        metricName=allMetricNames{metricIdx};

        if isMasked&&~isempty(traceMask)&&isfield(traceMask,metricName)
            locTraceMask=traceMask.(metricName);
        else
            locTraceMask=[];
        end

        this.reaggregateFromTrace(metricName,isTOmetric(metricIdx),locTraceMask)
    end
end
