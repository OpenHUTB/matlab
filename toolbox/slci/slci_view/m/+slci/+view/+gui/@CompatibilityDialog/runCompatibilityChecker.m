


function runCompatibilityChecker(obj)

    conf=slci.toolstrip.util.getConfiguration(obj.getStudio);

    stageName='compatibility';
    myStage=slci.internal.turnOnDiagnosticView(stageName,src.modelName);

    try
        conf.checkCompatibility;
    catch
    end

    myStage.delete

    obj.reloadData;

end