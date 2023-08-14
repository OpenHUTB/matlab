




function modelPause(modelH)
    try

        modelCovId=get_param(modelH,'CoverageId');
        if modelCovId==0
            return
        end
        coveng=cvi.TopModelCov.getInstance(modelH);
        invokedForSlicer=SlCov.CoverageAPI.isCovToolUsedBySlicer(modelH);


        if~invokedForSlicer

            cvi.TopModelCov.updateAutoscalingResults(coveng,true);


            if isempty(coveng.resultSettings)
                return;
            end

            if~(get_param(modelH,'IsStoppingInFastRestart')==1)&&...
                ~coveng.resultSettings.covReportOnPause
                return;
            end
        end

        if coveng.isLastReporting(modelH)
            if~isempty(coveng.embeddedCoderHookStatus)

                return
            end

            if~invokedForSlicer
                coveng.checkCumDataConsistency;
            end


            cvi.SLCustomCodeCov.pause(coveng,modelH);

            allModelcovIds=coveng.getAllModelcovIds;
            for currModelcovId=allModelcovIds(:)'

                cv('ModelPause',currModelcovId);
                if~coveng.isCvCmdCall&&~invokedForSlicer
                    currentTest=cv('get',currModelcovId,'.currentTest');
                    if currentTest~=0
                        updateResults(coveng,cvdata(currentTest));
                    end
                end
            end
            if~coveng.isCvCmdCall
                if invokedForSlicer
                    coveng.getDataResult;
                elseif~cvprivate('cv_autoscale_settings','isForce',modelH)
                    coveng.genResults();
                end
            end

            if get_param(modelH,'IsPausing')||get_param(modelH,'IsStoppingInFastRestart')


                cvi.TopModelCov.modelFastRestart(modelH,true);
            end

        end
        if invokedForSlicer
            SliceUtils.refreshSliceAtPause(modelH);
        end
    catch MEx
        rethrow(MEx);
    end
