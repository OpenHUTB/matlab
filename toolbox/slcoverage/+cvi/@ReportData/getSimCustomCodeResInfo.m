function[hitNums,codeCovRes,justifiedHitNums]=getSimCustomCodeResInfo(data,codeInfo,metricName)





    hitNums=[];
    codeCovRes=[];
    justifiedHitNums=0;


    if isempty(codeInfo.fileName)
        return
    end


    if isa(data,'cv.cvdatagroup')
        cvd=data.get(codeInfo.fileName);
    else
        cvd=data;
    end
    if isempty(cvd)||~cvd.isSimulinkCustomCode
        return
    end


    cCov=cvd.sfcnCovData;
    if isempty(cCov)||~hasResults(cCov)
        return
    end


    cCov=cCov.getAll();
    resObj=cCov(1);
    objs=resObj.findSourceLoc('',codeInfo.fcnName);
    if isempty(objs)
        return
    end

    [hitNums,codeCovRes,justifiedHitNums]=codeinstrum.internal.codecov.CodeCovData.getCodeResInfoForMatchedSourceLoc(resObj,objs,metricName);
