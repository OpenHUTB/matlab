function success=autotuneModel(cbinfo)




    success=true;
    topModel=cbinfo.model.Name;

    myStage=sldiagviewer.createStage(getString(message('dataflow:Spreadsheet:ProfilingStageName')),'ModelName',topModel);

    if~locCheckInfStopTime(topModel)
        return
    end


    [allMdls,modelBlocks]=multicoredesigner.internal.MappingData.updateDataModelHierarchy(get_param(topModel,'Handle'));


    [~,out]=evalc('sim(topModel, ''CaptureErrors'', ''on'')');
    meta=out.SimulationMetadata;

    numWarnings=numel(meta.ExecutionInfo.WarningDiagnostics);
    for idx=1:numWarnings
        meta.ExecutionInfo.WarningDiagnostics(idx).Diagnostic.reportAsWarning();
    end

    if~isempty(meta.ExecutionInfo.ErrorDiagnostic)
        meta.ExecutionInfo.ErrorDiagnostic.Diagnostic.reportAsError();
        success=false;
    end
end

function ret=locCheckInfStopTime(model)
    ret=true;
    stopTimeStr=get_param(model,'StopTime');
    try
        stopTime=evalin('base',stopTimeStr);
    catch
        try
            hws=get_param(model,'modelworkspace');
            stopTime=hws.evalin(stopTimeStr);
        catch
            stopTime=1;
        end
    end
    if isinf(stopTime)
        diag=MSLException([],message('dataflow:MultithreadingAnalysis:InfProfileError'));
        sldiagviewer.reportError(diag);
        ret=false;
    end
end


