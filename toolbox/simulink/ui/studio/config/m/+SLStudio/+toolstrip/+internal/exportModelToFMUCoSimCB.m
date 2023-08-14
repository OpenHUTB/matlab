



function exportModelToFMUCoSimCB(cbinfo)




    stage=sldiagviewer.createStage(getString(message('FMUExport:FMU:FMU2ExpCSCodeGenStage')),...
    'ModelName',SLStudio.Utils.getModelName(cbinfo));
    try
        dlgsrc=FMU2ExpCSDialog.CreatorDialog(SLStudio.Utils.getModelName(cbinfo));
        FMU2ExpCSDialog.showDialog(dlgsrc);
    catch e
        sldiagviewer.reportError(e);
    end
    stage.delete;
end
