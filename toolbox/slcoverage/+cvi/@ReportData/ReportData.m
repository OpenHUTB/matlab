




classdef ReportData<handle
    properties
testobjectiveData
metricData
cvd
    end
    methods
        function this=ReportData(allCvd)
            this.cvd=allCvd;
        end

        addTestobjectiveData(this,toMetricNames,allTests)
        addMetricData(this,metricName,allTests)
    end

    methods(Static=true)

        [hitNums,metricEnum,blockCvId,dataMat,codeCovRes,justifiedHitNums,cvd]=getHitCount(data,block,metricName,ignoreDescendants,includeAllSizes,covMode)
        [dataMat,out,justifiedHits]=getAPIMetricInfo(cvd,metricName,blockCvId,ignoreDescendants,includeAllSizes)
        updateDataIdx(data)
        codeDesc=getCodeCoverageInfo(codeCovRes,metricName,justifiedHit,isFiltered,filterRationale)
        [hitNums,codeCovRes,justifiedHitNums]=getSFunctionCodeResInfo(data,codeInfo,metricName)
        [hitNums,codeCovRes,justifiedHit]=getSimCustomCodeResInfo(data,codeInfo,metricName)
        [hitNums,codeCovRes,justifiedHit]=getECCodeResInfo(data,codeInfo,metricName,ignoreDescendants,covMode)
        function res=hasSourceLocInCodeCovRes(resObj,fileName,fcnName)
            res=~isempty(resObj.findSourceLoc(fileName,fcnName));
        end
        flags=getDecisionBlockFlag(decData)
        [hits,justifiedHits]=getHits(dataMat,idx,justifiedIdx,allColoumns)
    end
end
