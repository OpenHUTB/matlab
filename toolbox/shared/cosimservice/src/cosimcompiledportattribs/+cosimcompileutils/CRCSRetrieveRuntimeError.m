function errorStruct=CRCSRetrieveRuntimeError()
    errorStruct=struct('isError',false,'errorMsg','');
    try
        cosimoutput=evalin('base','cosim__output__');
        errorDiagnostic=cosimoutput.SimulationMetadata.ExecutionInfo.ErrorDiagnostic;
        if~isempty(errorDiagnostic)
            mlsDiagnostic=errorDiagnostic.Diagnostic;
            errorStruct.isError=true;
            eCause=MSLException(mlsDiagnostic);
            if ismethod(eCause,'json')
                errorStruct.errorMsg=eCause.json;
            else
                errorStruct.errorMsg=jsonencode(eCause);
            end
        end
    catch
    end
end