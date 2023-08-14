function err=i_saveSystem(mdlToBeSaved,mdlToBeSavedWithFullPath,varargin)






    err=[];
    try
        save_system(mdlToBeSaved,mdlToBeSavedWithFullPath,varargin{:});
    catch err
        if strcmp('Simulink:modelReference:SaveSystemWithDirtyReferencedModels',err.identifier)
            err=MException(message('Simulink:VariantReducer:InternalErrRefModelsDirty',mdlToBeSaved));
        end
    end
end
