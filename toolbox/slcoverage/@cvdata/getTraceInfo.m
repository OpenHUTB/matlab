function traceInfo=getTraceInfo(this,metricName,idx)




    try
        traceInfo=[];
        if~this.traceOn
            return;
        end



        if strcmp(metricName,'mcdcTrue')
            metricName='mcdc';
            isExecuted=getIsExecFcnForMcdc(this,true);
        elseif strcmp(metricName,'mcdcFalse')
            metricName='mcdc';
            isExecuted=getIsExecFcnForMcdc(this,false);
        else
            isExecuted=@isMetricExecuted;
        end



        tr=this.trace;
        traceSlice=[];

        if isfield(tr,metricName)&&...
            ~isempty(tr.(metricName))
            traceSlice=tr.(metricName)(idx,:);
        elseif isfield(tr,'testobjectives')&&...
            isfield(tr.testobjectives,metricName)&&...
            ~isempty(tr.testobjectives.(metricName))
            traceSlice=tr.testobjectives.(metricName)(idx,:);
        end

        if isempty(traceSlice)
            return;
        end





        traceSlice_IsExecuted=isExecuted(traceSlice);
        traceMask=[];
        if this.scopeDataToReqs
            traceMask=this.getTraceMask();
        end
        if isempty(traceMask)
            traceInfo=this.traceMap(traceSlice_IsExecuted);
        else
            mask=traceMask.(metricName);
            maskSlice=mask(idx,:);
            scoped_IsExecuted=traceSlice_IsExecuted&maskSlice;
            incidental_IsExecuted=traceSlice_IsExecuted&~maskSlice;
            scoped_TraceInfo=this.traceMap(scoped_IsExecuted);
            incidental_TraceInfo=this.traceMap(incidental_IsExecuted);
            traceInfo=[scoped_TraceInfo,incidental_TraceInfo];
        end

    catch MEx
        rethrow(MEx);
    end
end

function isExecutedFcn=getIsExecFcnForMcdc(cvd,entryType)
    if(cvd.modelinfo.mcdcMode==SlCov.McdcMode.UniqueCause)
        isExecutedFcn=@(x)zeros(size(x),'logical');
    elseif(entryType==true)
        isExecutedFcn=@isTrueOutHit;
    else
        isExecutedFcn=@isFalseOutHit;
    end
end

function res=isTrueOutHit(predSatStatus)
    res=(predSatStatus==SlCov.PredSatisfied.True_Only)|(predSatStatus==SlCov.PredSatisfied.Fully_Satisfied);
end

function res=isFalseOutHit(predSatStatus)
    res=(predSatStatus==SlCov.PredSatisfied.False_Only)|(predSatStatus==SlCov.PredSatisfied.Fully_Satisfied);
end

function res=isMetricExecuted(execCount)
    res=(execCount>0);
end
