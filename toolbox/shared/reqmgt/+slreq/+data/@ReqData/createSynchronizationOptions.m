function mfSyncOptions=createSynchronizationOptions(this,optionsStruct)






    mfSyncOptions=slreq.datamodel.SynchronizationOptions(this.model);

    if isstruct(optionsStruct)
        if isfield(optionsStruct,'ignoreWhiteSpace')
            mfSyncOptions.ignoreWhiteSpace=optionsStruct.ignoreWhiteSpace;
        end

        if isfield(optionsStruct,'diagnosticsMode')
            mfSyncOptions.diagnosticsMode=optionsStruct.diagnosticsMode;
        end
    end
end
