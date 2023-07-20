



function CheckCompatibilityTSCB(aObj)
    aObj.fViaGUI=true;
    stageName='compatibility check';
    myStage=slci.internal.turnOnDiagnosticView(stageName,aObj.getModelName);
    try
        slci.Configuration.saveObjToFile(aObj.getModelName(),aObj);
        aObj.checkCompatibility();

    catch ME
        aObj.HandleException(ME);
    end

    myStage.delete;

    aObj.fViaGUI=false;
end
