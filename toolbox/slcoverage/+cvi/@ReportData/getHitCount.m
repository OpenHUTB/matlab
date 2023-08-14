function[hitNums,metricEnum,newBlockCvId,dataMat,codeCovRes,justifiedHitNums,cvd]=getHitCount(indata,...
    block,metricName,ignoreDescendants,includeAllSizes,covMode)




    if nargin<6
        covMode=[];
    end

    cvprivate('check_cvdata_input',indata);

    blkPathObj=block;
    if isa(blkPathObj,'Simulink.BlockPath')
        block=blkPathObj.getBlock(blkPathObj.getLength);
    elseif iscell(block)&&isa(block{1},'Simulink.BlockPath')
        blkPathObj=block{1};
        block=block{2};
    end

    [data,blockCvId,newBlockCvId,portIdx,codeInfo]=...
    SlCov.CoverageAPI.getCvdata(indata,block,covMode);


    hitNums=[];
    justifiedHitNums=0;
    metricEnum=[];
    dataMat=[];
    codeCovRes=[];
    cvd=data;
    if~isempty(blockCvId)&&~ischar(blockCvId)&&blockCvId~=0...
        &&portIdx<=0
        metricEnum=cvi.MetricRegistry.getEnum(metricName);
        if codeInfo.mode~=SlCov.CovMode.Unknown

            if codeInfo.mode==SlCov.CovMode.SFunction
                [hitNums,codeCovRes,justifiedHitNums]=cvi.ReportData.getSFunctionCodeResInfo(data,codeInfo,metricName);
            elseif codeInfo.mode==SlCov.CovMode.SLCustomCode
                [hitNums,codeCovRes,justifiedHitNums]=cvi.ReportData.getSimCustomCodeResInfo(data,codeInfo,metricName);
            else
                [hitNums,codeCovRes,justifiedHitNums]=cvi.ReportData.getECCodeResInfo(data,codeInfo,metricName,ignoreDescendants,covMode);
            end
        else



            if cv('get',blockCvId,'.isDormant')
                return;
            end




            if isa(indata,'cv.cvdatagroup')&&isa(blkPathObj,'Simulink.BlockPath')
                data=indata.getRefCvDataForNormalMdlCopy(blkPathObj);
            end


            [dataMat,hitNums,justifiedHitNums]=cvi.ReportData.getAPIMetricInfo(...
            data,metricName,blockCvId,ignoreDescendants,...
            includeAllSizes);
        end
    end

end
