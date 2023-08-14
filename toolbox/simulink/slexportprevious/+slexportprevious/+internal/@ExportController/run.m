function run(obj)




    obj.guiHelper.setup(obj.sourceModelName)

    if~bdIsLoaded(obj.sourceModelName)
        DAStudio.error('Simulink:ExportPrevious:ModelNotLoaded',obj.sourceModelName);
    end

    obj.guiHelper.enable
    cleanup_waitbar=onCleanup(@()obj.guiHelper.disable);

    try
        obj.checkPreconditions;
        i_run(obj)
    catch E
        obj.guiHelper.handleError(E,obj.sourceModelName);
    end

end


function i_run(obj)

    needsCleanup=Simulink.harness.internal.convertToInternalHarnessesForExportToVersion(obj.sourceModelName);
    harnessCleanupObj=onCleanup(@()Simulink.harness.internal.postExportToVersionCleanup(obj.sourceModelName,needsCleanup));
    obj.targetModelHelper.createSnapshot(obj.sourceModelName)

    if~exist(obj.targetModelFile,'file')
        DAStudio.error('Simulink:ExportPrevious:AssertSnapshotCreation',obj.targetModelFile);
    end

    notifyOldModel=get_param(0,'NotifyIfLoadOldModel');
    set_param(0,'NotifyIfLoadOldModel','off');
    restore_notify=onCleanup(@()set_param(0,'NotifyIfLoadOldModel',notifyOldModel));

    w=warning('off','Simulink:Engine:MdlFileShadowing');
    restore_warning=onCleanup(@()warning(w));

    obj.guiHelper.setProgress(0.1);




    obj.preprocessHelper.progressFcn=...
    @(val)obj.guiHelper.setProgress(0.1+0.6*val);
    dynamicRules=obj.preprocessHelper.run(obj.sourceModelName);

    obj.targetModelHelper.restoreName;

    progressFcn=@(val)obj.guiHelper.setProgress(0.7+0.3*val);
    obj.postprocess(dynamicRules,progressFcn);

    obj.guiHelper.setProgress(1);

    obj.preprocessHelper.reportReplacedBlocks;

    obj.guiHelper.reportCompletion(obj.targetModelFile,~obj.failureFlag)



    obj.targetModelHelper.deleteBackup;

end


