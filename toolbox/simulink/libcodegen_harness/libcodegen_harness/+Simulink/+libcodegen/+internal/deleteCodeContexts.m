function deleteCodeContexts(modelHandle)



    codeContexts=Simulink.libcodegen.internal.getAllCodeContexts(modelHandle);
    for i=1:numel(codeContexts)
        currContext=codeContexts(i);
        Simulink.libcodegen.internal.deleteContext(currContext.model,currContext.name,currContext.ownerHandle);
    end
    if~isempty(codeContexts)
        MSLDiagnostic('Simulink:CodeContext:CodeContextExportToVersionWarning',getfullname(modelHandle)).reportAsWarning;
    end
end
