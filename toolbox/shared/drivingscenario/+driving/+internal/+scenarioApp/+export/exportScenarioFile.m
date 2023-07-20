function exportScenarioFile(toolStrip)
    try
        if isempty(toolStrip.Application.ActorSpecifications)&&isempty(toolStrip.Application.RoadSpecifications)
            ME=MException('DSD:OSCEmptyCanvas',getString(message('driving:scenario:OSCEmptyScenario')));
            throw(ME);
        elseif isempty(toolStrip.Application.ActorSpecifications)
            ME=MException('DSD:OSCNoActors',getString(message('driving:scenario:OSCNoActors')));
            throw(ME);
        end
        pos=toolStrip.Application.getCenterPosition([650,270]);
        dialog=driving.internal.openSCENARIOExport.openSCENARIO.DialogController(pos);
        dialog.attach(toolStrip.Application);
        dialog.open();
    catch ME
        errordlg(ME.message,getString(message('driving:scenarioApp:ExportOSCErrorDialogDescription')),'modal');
    end
end
