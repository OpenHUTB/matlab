function reduceModel(rManager)





























    cleanup=onCleanup(@()rManager.postProcessReduceModelError());





    [isInstalled,rManager.Error]=slvariants.internal.utils.getVMgrInstallInfo('Variant Reducer');
    if~isInstalled
        return;
    end



    if rManager.getOptions().GenerateReport
        [isSRPTCheckedOut,rManager.Error]=Simulink.variant.reducer.getSimulinkReportGenLicenseInfo();
        if~isSRPTCheckedOut
            return;
        end
    end


    tic;



    rManager.Error=rManager.validateIOArgs();
    if~isempty(rManager.Error)
        return;
    end



    rManager.Error=rManager.setupAbsOutDir();
    rManager.getOptions().GenerateLog=isempty(rManager.Error);


    if~isempty(rManager.Error)
        rManager.cleanUpModels(rManager.Error);
        return;
    end



    rManager.Error=rManager.preprocessInput();
    if~isempty(rManager.Error)
        rManager.getOptions().NewDirCreatedNoLog=false;
        rManager.cleanUpModels(rManager.Error);
        return;
    end


    rManager.ReportDataObj=Simulink.variant.reducer.summary.SummaryData(rManager.getOptions());






    rManager.getOptions().VerboseInfoObj.updateProgressBarMessage(...
    'Simulink:Variants:ReducerStatusMsgProcessConfigs');




    try




        rManager.Error=rManager.validateVariantActivationTimeForMultiConfig();
    catch ex %#ok<NASGU>
    end
    if~isempty(rManager.Error)
        rManager.cleanUpModels(rManager.Error);
        return;
    end





    rManager.applyConfigs();
    if~isempty(rManager.Error)
        rManager.cleanUpModels(rManager.Error);
        return;
    end
    rManager.getOptions().VerboseInfoObj.updateTimerMessage();





    rManager.getOptions().VerboseInfoObj.updateProgressBarMessage(...
    'Simulink:Variants:ReducerStatusMsgProcessLibs');
    rManager.processLibs();
    if~isempty(rManager.Error)
        rManager.cleanUpModels(rManager.Error);
        return;
    end




    rManager.Error=rManager.processConfigsForModels();
    if~isempty(rManager.Error)
        rManager.cleanUpModels(rManager.Error);
        return;
    end
    rManager.getOptions().VerboseInfoObj.updateTimerMessage();










    rManager.getOptions().VerboseInfoObj.updateProgressBarMessage(...
    'Simulink:Variants:ReducerStatusMsgRedMdls');

    rManager.Error=rManager.reduceBDCopies();
    if~isempty(rManager.Error)
        rManager.cleanUpModels(rManager.Error);
        return;
    end


    rManager.addBusSubsystemBlocks();

    rManager.analyzeDeps();

    rManager.Error=rManager.reduceMasks();
    if~isempty(rManager.Error)
        rManager.cleanUpModels(rManager.Error);
        return;
    end


    collectBlockPathsToLayout(rManager);

    rManager.saveBDCopies();
    if~isempty(rManager.Error)
        rManager.cleanUpModels(rManager.Error);
        return;
    end

    rManager.getOptions().VerboseInfoObj.updateTimerMessage();




    if rManager.getOptions().ValidateSignals
        rManager.getOptions().VerboseInfoObj.updateProgressBarMessage(...
        'Simulink:Variants:ReducerSignalAttributeMsg');
        rManager.collectPortAttributesForSSRefBlocks();
        try
            rManager.addSignalSpecificationBlocks();
        catch err
            Simulink.variant.reducer.utils.logException(err);
        end
        rManager.getOptions().VerboseInfoObj.updateTimerMessage();
    end


    collectBlockPathsToLayout(rManager);
    rManager.cleanUpSRFiles();

    rManager.saveBDCopies();


    rManager.getOptions().VerboseInfoObj.updateProgressBarMessage(...
    'Simulink:Variants:ReducerAutoLayout');
    try %#ok<TRYNC>
        rManager.layoutReducedModel();
    end
    rManager.getOptions().VerboseInfoObj.updateTimerMessage();



    rManager.getOptions().VerboseInfoObj.updateProgressBarMessage(...
    'Simulink:Variants:ReducerGenerateLog');
    rManager.generateReducerLog(rManager.Error);
    rManager.getOptions().VerboseInfoObj.updateTimerMessage();


    rManager.getOptions().VerboseInfoObj.updateProgressBarMessage(...
    'Simulink:Variants:ReducerStatusMsgSaveMdls');

    rManager.saveModelsAndDependencies();
    if~isempty(rManager.Error)
        rManager.cleanUpModels(rManager.Error);
        return;
    end
    rManager.getOptions().VerboseInfoObj.updateTimerMessage();




    rManager.getOptions().VerboseInfoObj.updateProgressBarMessage(...
    'Simulink:Variants:ReducerStatusMsgSaveCommonDeps');
    rManager.reduceAndSaveCommonDeps();
    rManager.getOptions().VerboseInfoObj.updateTimerMessage();



    rManager.setupReportData();


    rManager.getEnvironment().CausedByError=false;
    rManager.getOptions().GenerateLog=false;
    rManager.cleanUpModels();

end

function collectBlockPathsToLayout(rMgr)
    sysToLayout=unique(rMgr.SysHandlesToLayout);
    numHandlesToLayout=numel(sysToLayout);
    for idx=1:numHandlesToLayout
        try %#ok<TRYNC>
            blkName=getfullname(sysToLayout(idx));
            rMgr.SysPathsToLayout(blkName)=sysToLayout(idx);
        end
    end
end


