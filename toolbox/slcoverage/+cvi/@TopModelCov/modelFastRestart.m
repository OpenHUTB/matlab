




function modelFastRestart(modelH,fromModelPause)
    if nargin<2
        fromModelPause=false;
    end
    try
        coveng=cvi.TopModelCov.getInstance(modelH);
        if coveng.isLastReporting(modelH)
            if~isempty(coveng.embeddedCoderHookStatus)&&fromModelPause

                coveng.embeddedCoderHookStatus={'last_running','modelFastRestart'};
                return
            end
            lastReportingModelH=modelH;
            allModelcovIds=coveng.getAllModelcovIds;

            if coveng.isCvCmdCall
                coveng.getDataResult();
            end
            coveng.lastFastRestartData=[];
            for idx=1:numel(allModelcovIds)
                modelcovId=allModelcovIds(idx);

                if~cv('get',modelcovId,'.isScript')
                    modelH=cv('get',modelcovId,'.handle');
                    fromTestObj=cv('get',modelcovId,'.currentTest');
                    if modelH~=0&&fromTestObj~=0
                        isGeneratedCode=SlCov.CovMode.isGeneratedCode(cv('get',modelcovId,'.simMode'));
                        if~isGeneratedCode||fromModelPause

                            cv('set',modelcovId,'.activeTest',0);
                            cv('set',modelcovId,'.currentTest',0);
                        end
                        if~isGeneratedCode||(coveng.isCvCmdCall&&fromModelPause)
                            testId=initTest(coveng,modelH,modelcovId);
                            if testId~=0
                                copySettings(cvtest(testId),cvtest(fromTestObj));
                                filterData=cv('get',fromTestObj,'.filterData');
                                if~isempty(filterData)
                                    if~fromModelPause
                                        for jdx=1:numel(filterData)
                                            if strcmp(filterData(jdx).type,'startupvariant')




                                                filterData(jdx)=cvi.TopModelCov.createStartupVariantFilterData(modelH,testId);
                                            end
                                        end
                                    end
                                    cv('set',testId,'.filterData',filterData);
                                end
                                if~isGeneratedCode
                                    cv('set',testId,'.reducedBlocks',cv('get',fromTestObj,'.reducedBlocks'));
                                    allocateCovData(coveng,modelH);


                                    if~fromModelPause
                                        rootId=cv('get',modelcovId,'.activeRoot');
                                        cvi.TopModelCov.setUpFiltering(coveng.topModelH,cvdata(testId),rootId);
                                    end
                                end
                                coveng.lastFastRestartData=[coveng.lastFastRestartData,testId];
                            end
                        end
                    end
                end
            end

            newTestIds=cvi.SLCustomCodeCov.fastRestart(coveng,lastReportingModelH);
            coveng.lastFastRestartData=[coveng.lastFastRestartData,newTestIds];

            newTestIds=scriptFastRestart(coveng,lastReportingModelH);
            coveng.lastFastRestartData=[coveng.lastFastRestartData,newTestIds];
        end
    catch MEx
        rethrow(MEx);
    end


    function newTestIds=scriptFastRestart(coveng,modelH)
        newTestIds=[];
        if~isempty(coveng.scriptDataMap)


            for idx=1:numel(coveng.scriptDataMap)
                cvScriptId=coveng.scriptDataMap(idx).cvScriptId;
                modelcovId=cv('get',cvScriptId,'.modelcov');

                testId=cvtest.create(modelcovId);
                activeTestId=cv('get',modelcovId,'.activeTest');
                newTest=clone(cvtest(activeTestId),cvtest(testId));
                newTestId=newTest.id;
                activate(newTest,modelcovId);
                coveng.updateScriptinfo(newTestId,modelH,cvScriptId);
                cvi.TopModelCov.setTestObjective(modelcovId,newTestId);
                cv('allocateModelCoverageData',modelcovId);
                newTestIds=[newTestIds,newTestId];%#ok<AGROW>
            end
        end
