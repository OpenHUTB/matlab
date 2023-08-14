function updateResultsInModelsBlocks(topModel,runName)



    mdlRefTargetType=get_param(topModel,'ModelReferenceTargetType');
    targetName=slprivate('perf_logger_target_resolution',mdlRefTargetType,topModel,false,false);

    PerfTools.Tracer.logSimulinkData('Range Analysis For Autoscaling',...
    topModel,...
    targetName,...
    'Update Results',...
    true);

    cleanupObj=onCleanup(@()PerfTools.Tracer.logSimulinkData('Range Analysis For Autoscaling',...
    topModel,...
    targetName,...
    'Update Results',...
    false));

    try
        [~,refModelBlks]=SimulinkFixedPoint.AutoscalerUtils.getMdlRefs(topModel);
    catch failureToFindMdlRefs
        rethrow(failureToFindMdlRefs);
    end

    for i=1:length(refModelBlks)

        if strcmp(get_param(refModelBlks{i},'ProtectedModel'),'off')
            refModelHandle=get_param(refModelBlks{i},'Handle');
            modelAppdata=SimulinkFixedPoint.getApplicationData(get_param(refModelHandle,'ModelName'));
            subModelDataset=modelAppdata.dataset;
            instanceModelName=get_param(bdroot(refModelHandle),'Name');
            instanceAppData=SimulinkFixedPoint.getApplicationDataAsSubMdl(instanceModelName,refModelHandle);
            if instanceAppData.subDatasetMap.isKey(refModelHandle)
                modelBlkDataset=instanceAppData.subDatasetMap(refModelHandle);
                SimulinkFixedPoint.ApplicationData.updateMdlBlkDataset(subModelDataset,modelBlkDataset,runName);
            else

                instanceAppData.subDatasetMap(refModelHandle)=subModelDataset;
            end
        end
    end

    topModelAppData=SimulinkFixedPoint.getApplicationData(topModel);
    topModelAppData.dataset.setLastUpdatedRun(runName);
end





