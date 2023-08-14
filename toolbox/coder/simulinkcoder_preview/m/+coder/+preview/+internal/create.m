function out=create(sourceDD,type,name)




    if coder.preview.internal.CodePreview.isSupportedType(type)
        out=coder.preview.internal.CodePreview(sourceDD,type,name);
    elseif any(type==["FunctionClass","IRTFunction",...
        "PeriodicAperiodicFunction","SubcomponentEntryFunction",...
        "SharedUtilityFunction"])
        out=coder.preview.internal.ExecutionFunction(sourceDD,type,name);
    elseif type=="FunctionMemorySection"
        out=coder.preview.internal.FunctionMemorySection(sourceDD,type,name);
    else
        out=coder.preview.internal.ServiceInterface.create(sourceDD,type,name);
    end
