

function out=turnOnDiagnosticView(stageName,modelName)
    out=Simulink.output.Stage(stageName,'ModelName',modelName,'UIMode',true);
end