



function throwWarningsForDeprecatedOptions(obj)

    if isLegacyLargeModel(obj.mSldvOpts)
        throwWarning(obj,'Sldv:checkArgsOptions:LegacyLargeModel');
    end
end

function throwWarning(obj,warningId)

    msg=getString(message(warningId));
    sldvshareprivate('avtcgirunsupcollect','push',obj.mModelH,...
    'sldv_warning',msg,warningId);


    if~obj.mShowUI
        warning(message(warningId));
    end
end

function isLegacyLargeModel=isLegacyLargeModel(opts)
    isLegacyLargeModel=strcmp('TestGeneration',opts.Mode)&&...
    strcmp(opts.TestSuiteOptimization,'LargeModel (Nonlinear Extended)');
end
