





function out=InspectTSCB(aObj)

    aObj.fViaGUI=true;
    out=true;


    aObj.setShowReport(false);

    stageName='inspect';
    myStage=slci.internal.turnOnDiagnosticView(stageName,aObj.getModelName);

    try
        aObj.inspect;
    catch ME
        out=false;
        aObj.HandleException(ME);
    end

    myStage.delete;

    aObj.fViaGUI=false;
end
