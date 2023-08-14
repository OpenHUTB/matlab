function[hitNums,codeCovRes,justifiedHitNums]=getSFunctionCodeResInfo(data,codeInfo,metricName)





    hitNums=[];
    codeCovRes=[];
    justifiedHitNums=0;


    if~isa(data,'cvdata')
        return
    end


    if isempty(data.cachedSFcnCovInfoStruct)
        data.fillCachedSFcnCovInfoStruct();
    end


    if~data.cachedSFcnCovInfoStruct.covId2InstanceInfo.isKey(codeInfo.blockCvId)
        return
    end


    iInfo=data.cachedSFcnCovInfoStruct.covId2InstanceInfo(codeInfo.blockCvId);
    iIdx=iInfo.instanceIdx;
    resObj=data.cachedSFcnCovInfoStruct.allResults{1}(iInfo.name);

    objs=resObj.findSourceLoc(codeInfo.fileName,codeInfo.fcnName);
    if isempty(objs)
        return
    end

    [hitNums,codeCovRes,justifiedHitNums]=codeinstrum.internal.codecov.CodeCovData.getCodeResInfoForMatchedSourceLoc(resObj,objs,metricName,iIdx);
    if~isempty(codeCovRes)
        codeCovRes.isSFcnBlock=true;
    end
