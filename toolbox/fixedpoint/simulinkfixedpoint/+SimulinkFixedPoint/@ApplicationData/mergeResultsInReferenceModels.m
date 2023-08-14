function mergeResultsInReferenceModels(curSelectedSys,runName_universal)




    topModel=bdroot(curSelectedSys);
    mdlRefTargetType=get_param(topModel,'ModelReferenceTargetType');
    targetName=slprivate('perf_logger_target_resolution',mdlRefTargetType,topModel,false,false);

    PerfTools.Tracer.logSimulinkData('Range Analysis For Autoscaling',...
    topModel,...
    targetName,...
    'Merge results',...
    true);

    cleanupObj=onCleanup(@()PerfTools.Tracer.logSimulinkData('Range Analysis For Autoscaling',...
    topModel,...
    targetName,...
    'Merge results',...
    false));

    if isempty(runName_universal)
        runName_universal=get_param(topModel,'FPTRunName');
    end


    try
        [all_subMdls,~]=SimulinkFixedPoint.AutoscalerUtils.getMdlRefs(topModel);
    catch failureToFindMdlRefs
        rethrow(failureToFindMdlRefs);
    end



    for i=1:numel(all_subMdls)
        if~strcmp(all_subMdls{i},topModel)
            ad=SimulinkFixedPoint.getApplicationData(all_subMdls{i});
            subModelRunObj=ad.dataset.getRun(runName_universal);




            subModelRunObj.clearSimulationResults(subModelRunObj.getResults);
        end
    end

    for idx=1:length(all_subMdls)

        curTopMdl=all_subMdls{idx};
        try


            [~,refModelBlks]=find_mdlrefs(curTopMdl,'AllLevels',false,...
            'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
        catch failureToFindMdlRefs
            rethrow(failureToFindMdlRefs);
        end

        if~isempty(refModelBlks)
            appdata=SimulinkFixedPoint.getApplicationData(curTopMdl);
            if appdata.subDatasetMap.Count>0
                for i=1:length(refModelBlks)
                    refModelHandle=get_param(refModelBlks{i},'Handle');
                    if appdata.subDatasetMap.isKey(refModelHandle)
                        curDataset=appdata.subDatasetMap(refModelHandle);
                        modelAppdata=SimulinkFixedPoint.getApplicationData(get_param(refModelHandle,'ModelName'));
                        desDataset=modelAppdata.dataset;





                        modelAppdata.ScaleUsing=runName_universal;
                        SimulinkFixedPoint.ApplicationData.mergeRunsInDatasets(curDataset,desDataset,runName_universal);
                    end
                end
            end
        end
    end



