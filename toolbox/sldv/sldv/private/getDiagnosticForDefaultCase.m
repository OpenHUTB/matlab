function isSetToError=getDiagnosticForDefaultCase(blockH)




    if strcmp(get_param(blockH,'DiagnosticForDefault'),'Error')
        isSetToError=1;
    else
        isSetToError=0;
    end
end
