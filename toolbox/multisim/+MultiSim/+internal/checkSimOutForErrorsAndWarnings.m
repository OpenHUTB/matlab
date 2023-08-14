





function[hasErrors,hasWarnings]=checkSimOutForErrorsAndWarnings(simOut)
    md=simOut.SimulationMetadata;

    assert(~isempty(md),...
    'checkSimOutForErrorsAndWarnings: SimulationMetadata must not be empty');

    hasErrors=~isempty(simOut.SimulationMetadata.ExecutionInfo.ErrorDiagnostic);
    hasWarnings=~isempty(simOut.SimulationMetadata.ExecutionInfo.WarningDiagnostics);
end
