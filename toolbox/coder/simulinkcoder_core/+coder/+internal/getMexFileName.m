function mexFileName=getMexFileName...
    (modelName,codeFormat,mdlRefTargetType,...
    lProtectedModelReferenceTarget,isERTSfunction)









    mexFileName='';
    switch codeFormat
    case 'S-Function'
        mexFileName=[modelName,'_sf'];
    case 'Accelerator_S-Function'
        mexFileName=[modelName,'_acc'];
    otherwise
        if strcmpi(mdlRefTargetType,'SIM')
            ext=coder.internal.modelRefUtil(modelName,'getBinExt',lProtectedModelReferenceTarget);
            mexFileName=[modelName,ext];
        elseif isERTSfunction
            mexFileName=[modelName,'_sf'];
        end
    end
