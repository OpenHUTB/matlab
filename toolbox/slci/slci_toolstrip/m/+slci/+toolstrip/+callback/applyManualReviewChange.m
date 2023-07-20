


function applyManualReviewChange(cbinfo)
    mr_manager=slci.manualreview.Manager.getInstance;
    mr=mr_manager.getManualReview(cbinfo.studio);

    stageName='Export Manual Review';
    modelH=cbinfo.model.Handle;
    modelName=get_param(modelH,'Name');
    myStage=slci.internal.turnOnDiagnosticView(stageName,modelName);
    try

        mr.getDialog.exportData();
    catch e
        slci.internal.outputMessage(e,'error');
    end
    myStage.delete;
end