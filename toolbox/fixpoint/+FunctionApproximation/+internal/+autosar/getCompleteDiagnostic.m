function allDiagnostics=getCompleteDiagnostic(diagnosticsVector,parentMessageID)
















    if isempty(diagnosticsVector)
        allDiagnostics=MException.empty();
    else
        allDiagnostics=MException(message(parentMessageID));
        for iCause=1:numel(diagnosticsVector)
            allDiagnostics=allDiagnostics.addCause(diagnosticsVector(iCause));
        end
    end
end