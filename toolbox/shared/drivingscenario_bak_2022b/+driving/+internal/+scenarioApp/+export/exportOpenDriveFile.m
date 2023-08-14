function exportOpenDriveFile(toolStripApplication)




    try
        if isempty(toolStripApplication.RoadSpecifications)
            ME=MException('DSD:NoRoadNetwork',getString(message('driving:exportOpenDrive:EmptyScenario')));
            throw(ME);
        end

        pos=toolStripApplication.getCenterPosition([650,270]);
        dialog=driving.internal.scenarioExport.openDRIVE.DialogController(pos,toolStripApplication.ShowExportErrors);
        dialog.attach(toolStripApplication);
        dialog.open();
    catch ME
        toolStripApplication.ScenarioView.removeMessage('ExportODProgress');
        errordlg(ME.message,getString(message('driving:scenarioApp:ExportODErrorDialogDescription')),'modal');
    end
end
