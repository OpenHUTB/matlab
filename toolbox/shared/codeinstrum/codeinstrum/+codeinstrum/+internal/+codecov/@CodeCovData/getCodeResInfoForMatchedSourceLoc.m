



function[hitNums,codeCovRes,justifiedHitNums]=getCodeResInfoForMatchedSourceLoc(resObj,objs,metricName,instIdx)

    narginchk(3,4);

    if nargin<4||instIdx<0
        instIdx=[];
    end

    hitNums=[];
    codeCovRes=[];
    justifiedHitNums=0;
    res=[];

    metricKind=codeinstrum.internal.codecov.CodeCovData.getCodeCovResStructInfoForMetric(metricName);
    if isempty(metricKind)
        return
    end

    if metricKind==internal.cxxfe.instrum.MetricKind.CYCLO_CPLX

        hitNums=double(resObj.CodeTr.getCycloCplx(objs));
    else
        if isempty(instIdx)
            res=resObj.getAggregatedResults();
        else
            res=resObj.getInstanceResults(instIdx);
        end
        stats=res.getDeepMetricStats(objs,metricKind);
        if stats.metricKind==internal.cxxfe.instrum.MetricKind.UNKNOWN

            return
        end
        hitNums=double([stats.numCovered,stats.numNonExcluded]);
        justifiedHitNums=double(stats.numJustifiedUncovered);
        if hitNums(2)<1&&~stats.numTotal
            hitNums=[];
            return
        end
    end
    codeCovRes=struct('covRes',resObj,'objs',objs,'res',res);
