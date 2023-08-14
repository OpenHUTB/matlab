function scriptStart(coveng,modelH)



    try
        if~isempty(coveng.scriptDataMap)
            reloadCharts={};

            for idx=1:numel(coveng.scriptDataMap)
                scriptData=coveng.scriptDataMap(idx);
                if scriptData.isAllocated
                    continue;
                end
                oldRootId=scriptData.oldRootId;
                cvScriptId=scriptData.cvScriptId;
                modelcovId=cv('get',cvScriptId,'.modelcov');
                testId=cv('get',modelcovId,'.activeTest');
                coveng.updateScriptinfo(testId,modelH,cvScriptId);
                cv('compareCheckSumForScript',modelcovId,oldRootId);
                cvi.TopModelCov.setTestObjective(modelcovId,testId);
                cv('allocateModelCoverageData',modelcovId);
                coveng.scriptDataMap(idx).isAllocated=true;
                if(oldRootId~=0)
                    initScriptNumToCvIdMap(coveng);
                    oldCvScriptId=cv('get',cv('get',cv('get',modelcovId,'.activeRoot'),'.topSlsf'),'.treeNode.child');
                    if oldCvScriptId~=cvScriptId
                        coveng.scriptDataMap(idx).cvScriptId=oldCvScriptId;
                        chartIdStrs=scriptData.chartIdStrs;

                        for idx1=1:numel(chartIdStrs)
                            chartIdStr=chartIdStrs{idx1}{1};
                            instanceHandle=chartIdStrs{idx1}{2};
                            scriptNum=chartIdStrs{idx1}{3};
                            coveng.scriptNumToCvIdMap.(chartIdStr)(scriptNum+1)=oldCvScriptId;
                            reloadCharts{end+1}.chartIdStr=chartIdStr;
                            reloadCharts{end}.instanceHandle=instanceHandle;
                        end
                    end
                end
            end
            if~isempty(reloadCharts)
                reload_old_script_ids(coveng,reloadCharts)
            end
        end
    catch MEx
        rethrow(MEx);
    end


    function initScriptNumToCvIdMap(coveng)



        for idx=1:numel(coveng.scriptDataMap)
            scriptData=coveng.scriptDataMap(idx);
            chartIdStrs=scriptData.chartIdStrs;
            cvScriptId=scriptData.cvScriptId;
            for idx1=1:numel(chartIdStrs)
                chartIdStr=chartIdStrs{idx1}{1};
                scriptNum=chartIdStrs{idx1}{3};
                coveng.scriptNumToCvIdMap.(chartIdStr)(scriptNum+1)=cvScriptId;
            end
        end

        function reload_old_script_ids(coveng,reloadCharts)
            for idx=1:numel(reloadCharts)
                chartIdStr=reloadCharts{idx}.chartIdStr;
                instanceHandle=reloadCharts{idx}.instanceHandle;
                cvScriptIds=[coveng.scriptNumToCvIdMap.(chartIdStr)];
                covrtSetEmlScriptCvIds(instanceHandle,cvScriptIds);
            end
