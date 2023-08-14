



function[hitNums,codeCovRes,justifiedHitNums]=getECCodeResInfo(indata,codeInfo,metricName,ignoreDescendants,covMode)

    if isempty(ignoreDescendants)
        ignoreDescendants=false;
    end

    hitNums=[];
    codeCovRes=[];
    justifiedHitNums=0;

    if isa(indata,'cv.cvdatagroup')


        allData=indata.getAll(covMode);
    else
        allData={indata};
    end

    fileName='';
    fcnName='';
    blockCvId=codeInfo.blockCvId;
    useBlockInfo=~isempty(codeInfo.fileName);
    isBlockCvIdGood=~isempty(blockCvId);
    if~useBlockInfo&&~isBlockCvIdGood
        return
    end

    if~isBlockCvIdGood||useBlockInfo

        fileName=codeInfo.fileName;
        fcnName=codeInfo.fcnName;
    else

        metricKind=codeinstrum.internal.codecov.CodeCovData.getCodeCovResStructInfoForMetric(metricName);

        isTop=false;
        isATS=false;
        try
            if cv('get',blockCvId,'.isa')==1
                for ii=1:numel(allData)
                    if allData{ii}.rootId~=0
                        topCvId=cv('get',allData{ii}.rootId,'.topSlsf');

                        modelcovId=cv('get',allData{ii}.rootId,'.modelcov');
                        if cv('get',modelcovId,'.isScript')


                            topCvId=cv('get',topCvId,'.treeNode.child');
                        end



                        isATS=allData{ii}.isAtomicSubsystemCode();

                        isTop=topCvId==blockCvId;
                        if isTop||isATS

                            allData=allData(ii);
                            break
                        end
                    end
                end
            end
        catch
            isTop=false;
        end
        if~isTop&&(isempty(metricKind)||(metricKind==internal.cxxfe.instrum.MetricKind.CYCLO_CPLX))

            return
        end

        if(isTop&&~ignoreDescendants)||isATS
            fileName='';
            fcnName='';
            blockCvId=[];
        end
    end

    for ii=1:numel(allData)
        data=allData{ii};
        for jj=1:numel(data)
            cvd=data(jj);
            resObj=cvd.codeCovData;
            if isempty(resObj)
                continue
            end
            resObj.refreshModelCovIds(cvd);

            if isempty(blockCvId)||useBlockInfo||cvd.isCustomCode()||cvd.isSharedUtility()

                objs=resObj.findSourceLoc(fileName,fcnName);
                if isempty(objs)
                    continue
                end

                [hitNums,codeCovRes,justifiedHitNums]=codeinstrum.internal.codecov.CodeCovData.getCodeResInfoForMatchedSourceLoc(resObj,objs,metricName);
                if~isempty(hitNums)
                    return
                end
            else

                block=resObj.CodeTr.findSLModelElement(blockCvId);
                if isempty(block)
                    continue
                end

                res=resObj.getAggregatedResults();
                if ignoreDescendants||isa(block,'internal.cxxfe.instrum.SLBlock')

                    stats=res.getShallowMetricStats(block,metricKind);
                else
                    stats=res.getDeepMetricStats(block,metricKind);
                end

                if stats.metricKind==internal.cxxfe.instrum.MetricKind.UNKNOWN

                    continue
                end

                hitNums2=double([stats.numCovered,stats.numNonExcluded]);
                if hitNums2(2)<1
                    continue
                end
                hitNums=hitNums2;
                justifiedHitNums=double(stats.numJustifiedUncovered);
                codeCovRes=struct('covRes',resObj,'block',block,'res',res);
                return
            end
        end
    end

