function validateDDSModel(blkh)








    isModelRef=strcmpi(get_param(bdroot(blkh),'ModelReferenceTargetType'),'RTW');
    if isModelRef
        coder.internal.errorIf(true,'slrealtime:dds:blockNotAllowedInReference',get_param(blkh,'Parent'));
    end

end
