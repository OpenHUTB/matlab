classdef(Abstract)IModelBuildValidator<handle




    methods(Abstract)
        validate(~,iMdl,nTotalMdls,nLevels,targetType,mdlsHaveUnsavedChanges);
    end
end

