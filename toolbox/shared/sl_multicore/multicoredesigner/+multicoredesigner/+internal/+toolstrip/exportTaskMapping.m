function exportTaskMapping(cbinfo)




    model=cbinfo.model.Name;

    [matFile,matFilePath]=uiputfile('*.mat','Select a MAT File');
    if matFile==0
        return
    end

    mfModel=get_param(model,'MulticoreDataModel');
    mc=slmulticore.MulticoreConfig.getMulticoreConfig(mfModel);
    blocks=mc.blocks.toArray;


    blockPath={};
    task=[];
    pipelineStage=[];
    for b=blocks
        blockPath=[blockPath;b.path];
        task=[task;b.task.taskId];
        pipelineStage=[pipelineStage;b.pipelineStage];
    end
    multicoreAnalysisResults.mapping=table(blockPath,task,pipelineStage);


    appMgr=multicoredesigner.internal.UIManager.getInstance();
    uiObj=getMulticoreUI(appMgr,get_param(model,'Handle'));
    multicoreAnalysisResults.criticalPath=uiObj.MappingData.CriticalPathData;

    save(fullfile(matFilePath,matFile),'multicoreAnalysisResults')


