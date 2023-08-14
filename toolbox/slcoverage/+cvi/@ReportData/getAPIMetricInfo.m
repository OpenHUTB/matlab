function[dataMat,out,justifiedHits]=getAPIMetricInfo(cvd,metricName,blockCvId,ignoreDescendants,includeAllSizes)



    out=[];
    justifiedHits=[];

    try
        if isfield(cvd.metrics,metricName)
            dataMat=cvd.metrics.(metricName);
        elseif isfield(cvd.metrics,'testobjectives')&&isfield(cvd.metrics.testobjectives,metricName)
            dataMat=cvd.metrics.testobjectives.(metricName);
        end
    catch

        dataMat=[];
    end
    if isempty(dataMat)
        return;
    end

    if cvi.ReportUtils.checkInternalRationale(cvi.ReportUtils.getFilterRationale(blockCvId))

        return;
    end

    metricEnum=cvi.MetricRegistry.getEnum(metricName);

    [totalCnt,varTotalCntIdx,totalIdx,justifiedTotalIdx,...
    localCnt,varLocalCntIdx,localIdx,justifiedLocalIdx,...
    hasVariableSize,hasLocalVariableSize]=cv('MetricGet',blockCvId,metricEnum,...
    '.dataCnt.deep','.dataCnt.varDeepIdx','.dataIdx.deep','.justifiedDataIdx.deep',...
    '.dataCnt.shallow','.dataCnt.varShallowIdx','.dataIdx.shallow','.justifiedDataIdx.shallow',...
    '.hasVariableSize','.hasLocalVariableSize');
    if ignoreDescendants
        if localIdx<0
            return;
        end
        [hits,justifiedHits]=cvi.ReportData.getHits(dataMat,localIdx,justifiedLocalIdx,false);
        if hasLocalVariableSize
            varLocalCnt=dataMat(varLocalCntIdx+1);
            if includeAllSizes
                out=[hits,varLocalCnt,localCnt];
            else
                out=[hits,varLocalCnt];
            end
        else
            out=[hits,localCnt];
        end
    else
        if totalIdx<0
            return;
        end
        [hits,justifiedHits]=cvi.ReportData.getHits(dataMat,totalIdx,justifiedTotalIdx,false);


        if hasVariableSize
            varTotalCnt=dataMat(varTotalCntIdx+1);
            if includeAllSizes
                out=[hits,varTotalCnt,totalCnt];
            else
                out=[hits,varTotalCnt];
            end
        elseif hasLocalVariableSize
            varLocalCnt=dataMat(varLocalCntIdx+1);
            if includeAllSizes
                out=[hits,varLocalCnt,totalCnt];
            else
                out=[hits,varLocalCnt];
            end
        else
            out=[hits,totalCnt];
        end
    end
end

