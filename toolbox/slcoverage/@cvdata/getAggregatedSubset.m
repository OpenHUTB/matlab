function newCvd=getAggregatedSubset(this,traceIdxs)






    if isempty(this.trace)||(max(traceIdxs)>length(this.aggregatedTestInfo))
        newCvd=this;
        return;
    end


    [metricNames,toMetricNames]=getEnabledMetricNames(this);
    deleteIdx=contains(metricNames,{'sigrange','sigsize'});
    metricNames(deleteIdx==1)=[];
    allMetricNames=[metricNames,toMetricNames];
    isTOmetric=[zeros(1,numel(metricNames)),ones(1,numel(toMetricNames))];


    traceStruct=[];
    for metricIdx=1:length(allMetricNames)
        metricName=allMetricNames{metricIdx};

        if isTOmetric(metricIdx)
            tmpTrace=this.trace.testobjectives.(metricName);
            traceStruct.testobjectives.(metricName)=tmpTrace(:,traceIdxs);
        else
            tmpTrace=this.trace.(metricName);
            traceStruct.(metricName)=tmpTrace(:,traceIdxs);
        end

    end


    tmpCvd=cvdata;
    tmpCvd.createDerivedData(this,this,this.metrics,traceStruct);
    tmpCvd.aggregatedTestInfo=this.aggregatedTestInfo(traceIdxs);



    thisTraceMask=this.getTraceMask;
    for metricIdx=1:length(allMetricNames)
        metricName=allMetricNames{metricIdx};


        locTraceMask=[];
        if~isempty(thisTraceMask)&&isfield(thisTraceMask,metricName)
            tmpTraceMask=thisTraceMask.(metricName);
            tmpCvd.traceMask.(metricName)=tmpTraceMask(:,traceIdxs);
            if tmpCvd.scopeDataToReqs


                locTraceMask=tmpCvd.traceMask.(metricName);
            end
        end

        tmpCvd.reaggregateFromTrace(metricName,isTOmetric(metricIdx),locTraceMask)
    end

    newCvd=commitdd(tmpCvd);
end


