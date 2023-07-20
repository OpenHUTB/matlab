




function modelTerm(modelH)
    try
        compileForCoverage=strcmpi(get_param(modelH,'compileForCoverageInProgress'),'on');
        invokedForSlicer=SlCov.CoverageAPI.isCovToolUsedBySlicer(modelH);
        modelCovId=get_param(modelH,'CoverageId');
        if modelCovId==0
            return
        end
        coveng=cvi.TopModelCov.getInstance(modelH);
        if~isempty(coveng.simscapeCov)
            coveng.simscapeCov.term();
        end

        if coveng.isLastReporting(modelH)

            if~isempty(coveng.embeddedCoderHookStatus)

                coveng.embeddedCoderHookStatus={'last_running','modelTerm'};
                return
            end
            coveng.coderCov.modelTerm();
            allModelcovIds=coveng.getAllModelcovIds;
            topModelcovId=cv('get',modelCovId,'.topModelcovId');
            if~compileForCoverage&&~checkUnfinishedInitialization(topModelcovId,allModelcovIds)


                allModelcovIds=cvi.TopModelCov.removeEliminatedModels(topModelcovId);




                for currModelcovId=allModelcovIds(:)'
                    coveng.keepHarnessCvData=cvi.TopModelCov.isRootMergePossible(currModelcovId);
                    coveng.initHarnessInfo(currModelcovId);
                    cvi.SLCustomCodeCov.addResults(coveng,currModelcovId);
                end
                cvi.SLCustomCodeCov.addResults(coveng);
                cvi.SLCustomCodeCov.term(coveng,modelH);



                allModelcovIds=coveng.getAllModelcovIds;

                for currModelcovId=allModelcovIds(:)'
                    cv('ModelcovTerm',currModelcovId);
                end
                if~cvprivate('cv_autoscale_settings','isForce',modelH)&&~invokedForSlicer
                    coveng.checkCumDataConsistency;
                end
                fastRestartEnd=(get_param(modelH,'InteractiveSimInterfaceExecutionStatus')==2);

                if invokedForSlicer

                    coveng.getDataResult;
                else
                    isOnlyAutoscale=cvi.TopModelCov.updateAutoscalingResults(coveng,false);
                    if~isOnlyAutoscale&&~fastRestartEnd
                        if coveng.isCvCmdCall
                            res=coveng.getDataResult;
                            if~isempty(res)&&SlCov.CoverageAPI.feature('results')


                                cvi.ResultsExplorer.ResultsExplorer.setChecksum(get_param(modelH,'name'),res);
                            end
                        else
                            if~isEmptyDataFromSimStepStop(coveng)
                                coveng.genResults();
                            end
                        end
                    end
                end
            end
            cleanUp(allModelcovIds);
            if~coveng.isCvCmdCall
                cvi.TopModelCov.termFromTopModel(modelH);
            end

        end
    catch MEx
        cleanUp(coveng.getAllModelcovIds);
        rethrow(MEx);
    end

    function res=isEmptyDataFromSimStepStop(coveng)




        refModelCovObjs=coveng.getAllModelcovIds;
        res=[];
        if~isempty(refModelCovObjs)
            allTestIds=num2cell(cv('get',refModelCovObjs,'.currentTest')');
            res=false;
            for idx=1:numel(allTestIds)
                cId=allTestIds{idx};
                if any(coveng.lastFastRestartData==cId)
                    cvd=cvdata(cId);
                    if cvd.simulationStopTime==0&&cvd.isEmpty
                        res=true;
                    else
                        res=false;
                        return;
                    end
                end
            end
        end



        function cleanUp(allModelcovIds)

            for currModelcovId=allModelcovIds(:)'
                cv('ModelcovClear',currModelcovId);
            end


            function res=checkUnfinishedInitialization(topModelcovId,allModelcovIds)




                if~ismember(topModelcovId,allModelcovIds)
                    res=false;
                    return;
                end


                currentTestId=cv('get',topModelcovId,'.currentTest');
                res=(currentTestId==0);

