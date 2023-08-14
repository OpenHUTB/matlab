function newTestIds=fastRestart(coveng,modelH)









    newTestIds=[];
    if~coveng.isLastReporting(modelH)
        return
    end


    cvi.SFunctionCov.fastRestart(coveng);


    if~SlCov.isSLCustomCodeCovFeatureOn()
        return
    end


    extraData=struct();
    if strcmp(get_param(coveng.topModelH,'CovUseTimeInterval'),'on')
        extraData.startRecTime=get_param(coveng.topModelH,'CovStartTime');
        extraData.stopRecTime=get_param(coveng.topModelH,'CovStopTime');
    end


    covIds=coveng.slccCov.covId2ScriptName.keys();
    for ii=1:numel(covIds)
        modelcovId=covIds{ii};
        actTestId=cv('get',modelcovId,'.activeTest');
        testId=cvtest.create(modelcovId);
        newTestIds=[newTestIds,testId];%#ok<AGROW>
        cvt=cvtest(testId);
        copySettings(cvt,cvtest(actTestId));
        activate(cvt,modelcovId);
        cvi.TopModelCov.updateSimulationOptimizationOptions(testId,coveng.topModelH);
        cvi.TopModelCov.setTestObjective(modelcovId,testId);
        cv('allocateModelCoverageData',modelcovId);
    end


    libNames=coveng.slccCov.libName2Info.keys();
    for ii=1:numel(libNames)
        libInfo=coveng.slccCov.libName2Info(libNames{ii});
        if isempty(libInfo.dbFile)
            continue
        end

        internal.slcc.cov.LibUtils.clearCoverage(libInfo.libPath);

        if isempty(libInfo.instances)
            continue
        end

        allResFiles=unique({libInfo.instances.dbFile});
        for jj=1:numel(allResFiles)
            internal.cxxfe.instrum.runtime.ResultHitsManager.updateExtraDatas(allResFiles{jj},extraData);
        end
    end
